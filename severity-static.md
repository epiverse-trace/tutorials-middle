---
title: 'Estimation of outbreak severity'
teaching: 10
exercises: 2
editor_options: 
  chunk_output_type: inline
---

:::::::::::::::::::::::::::::::::::::: questions 

- Why do we estimate the clinical severity of an epidemic?

- How can the Case Fatality Risk (CFR) be estimated early in an ongoing epidemic?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Estimate the CFR from aggregated case data using `{cfr}`.

- Estimate a delay-adjusted CFR using `{epiparameter}` and `{cfr}`.

- Estimate a delay-adjusted severity for an expanding time series using `{cfr}`.

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: prereq

## Prerequisites

This episode requires you to be familiar with:

**Data science**: Basic programming with R.

**Epidemic theory**: [Delay distributions](../learners/reference.md#delaydist).

:::::::::::::::::::::::::::::::::

## Introduction

Common questions at the early stage of an epidemic include:

- What is the likely public health impact of the outbreak in terms of clinical severity?
- What are the most severely affected groups?
- Does the outbreak have the potential to cause a very severe pandemic?

We can assess the pandemic potential of an epidemic with two critical measurements: the transmissibility and the clinical severity
([Fraser et al., 2009](https://www.science.org/doi/full/10.1126/science.1176062), 
[CDC, 2016](https://www.cdc.gov/flu/pandemic-resources/national-strategy/severity-assessment-framework-508.html)).

![HHS Pandemic Planning Scenarios based on the Pandemic Severity Assessment Framework. This uses a combined measure of clinical severity and transmissibility to characterise influenza pandemic scenarios. **HHS**: United States Department of Health and Human Services ([CDC, 2016](https://www.cdc.gov/flu/pandemic-resources/national-strategy/severity-assessment-framework-508.html)).](fig/cfr-hhs-scenarios-psaf.png){alt='The horizontal axis is the scaled measure of clinical severity, ranging from 1 to 7, where 1 is low, 4 is moderate, and 7 is very severe. The vertical axis is the scaled measure of transmissibility, ranging from 1 to 5, where 1 is low, 3 is moderate, and 5 is highly transmissible. On the graph, HHS pandemic planning scenarios are labeled across four quadrants (A, B, C and D). From left to right, the scenarios are “seasonal range,” “moderate pandemic,” “severe pandemic” and “very severe pandemic.” As clinical severity increases along the horizontal axis, or as transmissibility increases along the vertical axis, the severity of the pandemic planning scenario also increases.'}

One epidemiological approach to estimating the clinical severity is quantifying the Case Fatality Risk (CFR). CFR is the conditional probability of death given confirmed diagnosis, calculated as the cumulative number of deaths from an infectious disease over the number of confirmed diagnosed cases. However, calculating this directly during the course of an epidemic tends to result in a naive or biased CFR given the time [delay](../learners/reference.md#delaydist) from onset to death, varying substantially as the epidemic progresses and stabilising at the later stages of the outbreak ([Ghani et al., 2005](https://academic.oup.com/aje/article/162/5/479/82647?login=false#620743)).

![Observed biased confirmed case fatality risk (CFR) estimates as a function of time (thick line) calculated as the cumulative number 
of deaths over confirmed cases at time t. The estimate at the end of an outbreak (~May 30) is the realised CFR by the end of the epidemic.
 The horizontal continuous line and dotted lines show the expected value and the 95% confidence intervals ($95\%$ CI) of the predicted delay-adjusted 
 CFR estimate only by using the observed data until 27 Mar 2003
  ([Nishiura et al., 2009](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0006852))](fig/cfr-pone.0006852.g003-fig_c.png){alt='The periods are relevant: Period 1 -- 15 days where CFR is zero to indicate this is due to no reported deaths; Period from Mar 15 -- Apr 26 where CFR appears to be rising; Period Apr 30 -- May 30 where the CFR estimate stabilises.'}

::::::::::::::::::::::: instructor

The periods are relevant: Period 1 -- 15 days where CFR is zero to indicate this is due to no reported deaths; Period from Mar 15 -- Apr 26 where CFR appears to be rising; Period Apr 30 -- May 30 where the CFR estimate stabilises.

:::::::::::::::::::::::

More generally, estimating severity can be helpful even outside of a pandemic planning scenario and in the context of routine public health. 
Knowing whether an outbreak has or had a different severity from the historical record can motivate causal investigations, 
which could be intrinsic to the infectious agent (e.g., a new, more severe strain) or due to underlying factors in the population (e.g. reduced immunity or morbidity factors) ([Lipsitch et al., 2015](https://journals.plos.org/plosntds/article?id=10.1371/journal.pntd.0003846)).

In this tutorial we are going to learn how to use the `{cfr}` package to calculate and adjust a CFR estimation using [delay distributions](../learners/reference.md#delaydist) from `{epiparameter}` or elsewhere, based on the methods developed by [Nishiura et al., 2009](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0006852), also, how we can reuse `{cfr}` functions for more severity measurements.

We’ll use the pipe `%>%` operator to connect  functions, so let’s also call to the `{tidyverse}` package:


``` r
library(cfr)
library(epiparameter)
library(tidyverse)
library(outbreaks)
```

::::::::::::::::::: checklist

### The double-colon

The double-colon `::` in R let you call a specific function from a package without loading the entire package into the current environment. 

For example, `dplyr::filter(data, condition)` uses `filter()` from the `{dplyr}` package.

This help us remember package functions and avoid namespace conflicts.

:::::::::::::::::::

:::::::::::::::::::: discussion

Based on your experience:

- Share any previous outbreak in which you participated in its response.

Answer to these questions:

- How did you assess the clinical severity of the outbreak?
- What were the primary sources of bias?
- What did you do to take into account the identified bias?
- What complementary analysis would you do to solve the bias?

:::::::::::::::::::: 

## Data sources for clinical severity

What are data sources can we use to estimate the clinical severity of a disease outbreak? [Verity et al., 2020](https://www.thelancet.com/journals/laninf/article/PIIS1473-3099(20)30243-7/fulltext) summarises the spectrum of COVID-19 cases:

![Spectrum of COVID-19 cases. The CFR aims to estimate the proportion of Deaths among confirmed cases in an epidemic. 
([Verity et al., 2020](https://www.thelancet.com/journals/laninf/article/PIIS1473-3099(20)30243-7/fulltext#gr1))](fig/cfr-spectrum-cases-covid19.jpg)

- At the top of the pyramid, those who met the WHO case criteria for **severe** or critical cases would likely have been identified in the hospital setting, presenting with atypical viral pneumonia. These cases would have been identified in mainland China and among those categorised internationally as local transmission. 
- Many more cases are likely to be **symptomatic** (i.e., with fever, cough, or myalgia) but might not require hospitalisation. These cases would have been identified through links to international travel to high-risk areas and through contact-tracing of contacts of confirmed cases. They might be identifiable through population surveillance of, for example, influenza-like illness. 
- The bottom part of the pyramid represents **mild** (and possibly **asymptomatic**) cases. These cases might be identifiable through contact tracing and subsequently via serological testing.


## Naive CFR

We measure disease severity in terms of case fatality risk (CFR). The CFR is interpreted as the conditional probability of death given confirmed diagnosis, calculated as the cumulative number of deaths $D_{t}$ over the cumulative number of confirmed cases $C_{t}$ at a certain time $t$. We can refer to the _naive CFR_ (also crude or biased CFR, $b_{t}$):

$$ b_{t} =  \frac{D_{t}}{C_{t}} $$

This calculation is _naive_ because it tends to yield a biased and mostly underestimated CFR due to the time-delay from onset to death, only stabilising at the later stages of the outbreak.

<!-- add here the callout on ratio or risk?  -->
<!-- https://github.com/epiverse-trace/cfr/issues/130 -->

To calculate the naive CFR, the `{cfr}` package requires an input data frame with three columns named:

- `date`
- `cases`
- `deaths`

Let's explore the `ebola1976` dataset, included in {cfr}, which comes from the first Ebola outbreak in what was then called Zaire (now the Democratic Republic of the Congo) in 1976, as analysed by Camacho et al. (2014).


``` r
# Load the Ebola 1976 data provided with the {cfr} package
data("ebola1976")

# Assume we only have the first 30 days of this data
ebola_30days <- ebola1976 %>%
  dplyr::slice_head(n = 30) %>%
  dplyr::as_tibble()

ebola_30days
```

``` output
# A tibble: 30 × 3
   date       cases deaths
   <date>     <int>  <int>
 1 1976-08-25     1      0
 2 1976-08-26     0      0
 3 1976-08-27     0      0
 4 1976-08-28     0      0
 5 1976-08-29     0      0
 6 1976-08-30     0      0
 7 1976-08-31     0      0
 8 1976-09-01     1      0
 9 1976-09-02     1      0
10 1976-09-03     1      0
# ℹ 20 more rows
```

:::::::::::::::::: callout

### We need aggregated incidence data

`{cfr}` reads **aggregated** incidence data. 

<!-- Similar to the `{EpiNow2}` with the difference that for `{cfr}` we need one more column named `deaths`. -->



This data input should be **aggregated** by day, which means one observation *per day*, containing the *daily* number of reported cases and deaths. Observations with zero or missing values should also be included, similar to time-series data.

Also, `{cfr}` currently works for *daily* data only, but not for other temporal units of data aggregation, e.g., weeks.

<!-- suggest ways to deal with raw input weekly data -->
<!-- https://github.com/epiverse-trace/cfr/issues/117 -->

::::::::::::::::::

When we apply `cfr_static()` to `data` directly, we are calculating the naive CFR:


``` r
# Calculate the naive CFR for the first 30 days
cfr::cfr_static(data = ebola_30days)
```

``` output
  severity_estimate severity_low severity_high
1         0.4740741    0.3875497     0.5617606
```

:::::::::::::::::::::::::::::::::::::::: challenge

Download the file [sarscov2_cases_deaths.csv](data/sarscov2_cases_deaths.csv) and read it into R. 

Estimate the naive CFR.

:::::::::::::::::::: hint

Inspect the format of the data input.

- Does it contain daily data?
- Does the column names are as required by `cfr_static()`?
- How would you rename column names from a data frame?

::::::::::::::::::::

:::::::::::::::::::: solution

We read the data input using `readr::read_csv()`. This function recognize that the column `date` is a `<date>` class vector.




``` r
# read data
# e.g.: if path to file is data/raw-data/ebola_cases.csv then:
sarscov2_input <-
  readr::read_csv(here::here("data", "raw-data", "sarscov2_cases_deaths.csv"))
```


``` r
# Inspect data
sarscov2_input
```

``` output
# A tibble: 93 × 3
   date       cases_jpn deaths_jpn
   <date>         <dbl>      <dbl>
 1 2020-01-20         1          0
 2 2020-01-21         1          0
 3 2020-01-22         0          0
 4 2020-01-23         1          0
 5 2020-01-24         1          0
 6 2020-01-25         3          0
 7 2020-01-26         3          0
 8 2020-01-27         4          0
 9 2020-01-28         6          0
10 2020-01-29         7          0
# ℹ 83 more rows
```

We can use `dplyr::rename()` to adapt the external data to fit the data input for `cfr_static()`.


``` r
# Rename before Estimate naive CFR
sarscov2_input %>%
  dplyr::rename(
    cases = cases_jpn,
    deaths = deaths_jpn
  ) %>%
  cfr::cfr_static()
```

``` output
  severity_estimate severity_low severity_high
1        0.01895208   0.01828832    0.01963342
```

::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::

## Biases that affect CFR estimation

::::::::::::::::::::::::::::: discussion

### Two biases that affect CFR estimation

[Lipsitch et al., 2015](https://journals.plos.org/plosntds/article?id=10.1371/journal.pntd.0003846) describe two potential biases that can affect the estimation of CFR (and their potential solutions):

:::::::::::::::::::::::::::::

::::::::::::: solution

### 1. Preferential ascertainment of severe cases

For diseases with a _spectrum_ of clinical presentations, those cases that come to the attention of public health authorities and registered into surveillance databases will typically be people with the most severe symptoms who seek medical care, are admitted to a hospital, or die. 

Therefore, the CFR will typically be higher among _detected cases_ than among the entire population of cases, given that the latter may include individuals with mild, subclinical, and (under some definitions of “case”) asymptomatic presentations.

:::::::::::::

:::::::::::: solution

### 2. Bias due to delayed reporting of death

During an _ongoing_ epidemic, there is a delay between the time someone dies and the time their death is reported. Therefore, at any given moment in time, the list of cases includes people who will die and whose death has not yet occurred or has occurred but not yet been reported. Thus, dividing the cumulative number of reported deaths by the cumulative number of reported cases at a specific time point during an outbreak will underestimate the true CFR.

The key determinants of the magnitude of the bias are the epidemic _growth rate_ and the _distribution of delays_ from case-reporting to death-reporting; the longer the delays and the faster the growth rate, the greater the bias.

In this tutorial episode, we are going to focus on solutions to deal with this specific bias using `{cfr}`!

::::::::::::

:::::::::::::::::::: solution

### Case study: Influenza A (H1N1), Mexico, 2009

Improving an _early_ epidemiological assessment of a delay-adjusted CFR is crucial for determining virulence, shaping the level and choices of public health intervention, and providing advice to the general public. 

In 2009, during the swine-flu virus, Influenza A (H1N1), Mexico had an early biased estimation of the CFR. Initial reports from the government of Mexico suggested a virulent infection, whereas, in other countries, the same virus was perceived as mild ([TIME, 2009](https://content.time.com/time/health/article/0,8599,1894534,00.html)).

In the USA and Canada, no deaths were attributed to the virus in the first ten days following the World Health Organization's declaration of a public health emergency. Even under similar circumstances at the early stage of the global pandemic, public health officials, policymakers and the general public want to know the virulence of an emerging infectious agent.

[Fraser et al., 2009](https://www.science.org/doi/full/10.1126/science.1176062) reinterpreted the data assessing the biases and getting a clinical severity lower than the 1918 influenza pandemic but comparable with that seen in the 1957 pandemic.

::::::::::::::::::::

:::::::::::::::::::: instructor

We can showcase this last bias using the [concept described in this `{cfr}` vignette](https://epiverse-trace.github.io/cfr/articles/cfr.html#concept-how-reporting-delays-bias-cfr-estimates).

<!-- create code and then a .gif? -->

::::::::::::::::::::

## Delay-adjusted CFR

[Nishiura et al., 2009](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0006852) developed a method that considers the **time delay** from the onset of symptoms to death.

Real-time outbreaks may have a number of deaths that are insufficient to determine the time distribution between onset and death. Therefore, we can estimate the _distribution delay_ from historical outbreaks or reuse the ones accessible via R packages like `{epiparameter}` or `{epireview}`, which collect them from published scientific literature. For an step-by-step guide, read the tutorial episode on how to [access to epidemiological delays](https://epiverse-trace.github.io/tutorials-early/delays-reuse.html).

Let's use `{epiparameter}`:


``` r
# Get delay distribution
onset_to_death_ebola <-
  epiparameter::epiparameter_db(
    disease = "Ebola",
    epi_name = "onset_to_death",
    single_epiparameter = TRUE
  )

# Plot <epidist> object
plot(onset_to_death_ebola, day_range = 0:40)
```

<img src="fig/severity-static-rendered-unnamed-chunk-9-1.png" style="display: block; margin: auto;" />

To calculate the delay-adjusted CFR, we can use the `cfr_static()` function with the `data` and `delay_density` arguments.


``` r
# Calculate the delay-adjusted CFR
# for the first 30 days
cfr::cfr_static(
  data = ebola_30days,
  delay_density = function(x) density(onset_to_death_ebola, x)
)
```

``` output
  severity_estimate severity_low severity_high
1            0.9502        0.881        0.9861
```



The delay-adjusted CFR indicated that the overall disease severity _at the end of the outbreak_ or with the _latest data available at the moment_ is 0.9502 with a 95% confidence interval between 0.881 and 0.9861, slightly higher than the naive one.

:::::::::::::::::: callout

### Use the epidist class

When using an `<epidist>` class object we can use this expression as a template:

`function(x) density(<EPIDIST_OBJECT>, x)`

For distribution functions with parameters not available in `{epiparameter}`, we suggest you two alternatives: 

- Create an `<epidist>` class object, to plug into other R packages of the outbreak analytics pipeline. Read the [reference documentation of `epiparameter::epidist()`](https://epiverse-trace.github.io/epiparameter/reference/epidist.html), or

- Read `{cfr}` vignette for [a primer on working with delay distributions](https://epiverse-trace.github.io/cfr/articles/delay_distributions.html).

::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: challenge

Use the same file from the previous challenge ([sarscov2_cases_deaths.csv](data/sarscov2_cases_deaths.csv)).

Estimate the delay-adjusted CFR using the appropriate distribution delay. Then:

- Compare the naive and the delay-adjusted CFR solutions!

:::::::::::::::::::: hint

- Find the appropriate `<epidist>` object!

::::::::::::::::::::

:::::::::::::::::::: solution

We use `{epiparameter}` to access a delay distribution for the SARS-CoV-2 aggregated incidence data:


``` r
library(epiparameter)

sarscov2_delay <-
  epiparameter::epiparameter_db(
    disease = "covid",
    epi_name = "onset to death",
    single_epiparameter = TRUE
  )
```

We read the data input using `readr::read_csv()`. This function recognize that the column `date` is a `<date>` class vector.




``` r
# read data
# e.g.: if path to file is data/raw-data/ebola_cases.csv then:
sarscov2_input <-
  readr::read_csv(here::here("data", "raw-data", "sarscov2_cases_deaths.csv"))
```


``` r
# Inspect data
sarscov2_input
```

``` output
# A tibble: 93 × 3
   date       cases_jpn deaths_jpn
   <date>         <dbl>      <dbl>
 1 2020-01-20         1          0
 2 2020-01-21         1          0
 3 2020-01-22         0          0
 4 2020-01-23         1          0
 5 2020-01-24         1          0
 6 2020-01-25         3          0
 7 2020-01-26         3          0
 8 2020-01-27         4          0
 9 2020-01-28         6          0
10 2020-01-29         7          0
# ℹ 83 more rows
```

We can use `dplyr::rename()` to adapt the external data to fit the data input for `cfr_static()`.


``` r
# Rename before Estimate naive CFR
sarscov2_input %>%
  dplyr::rename(
    cases = cases_jpn,
    deaths = deaths_jpn
  ) %>%
  cfr::cfr_static(
    delay_density = function(x) density(sarscov2_delay, x)
  )
```

``` output
  severity_estimate severity_low severity_high
1            0.0734        0.071        0.0759
```

Interpret the comparison between the naive and delay-adjusted CFR estimates.

::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::: spoiler

### When to use discrete distributions?

For  `cfr_static()` and all the `cfr_*()` family of functions, the most appropriate choice to pass are **discrete** distributions. This is because we will work with daily case and death data.

We can assume that evaluating the Probability Distribution Function (PDF) of a *continuous* distribution is equivalent to the Probability Mass Function (PMF) of the equivalent *discrete* distribution.

However, this assumption may not be appropriate for distributions with larger peaks. For instance, diseases with an onset-to-death distribution that is strongly peaked with a low variance. In such cases, the average disparity between the PDF and PMF is expected to be more pronounced compared to distributions with broader spreads. One way to deal with this is to discretise the continuous distribution using `epiparameter::discretise()` to an `<epidist>` object.

::::::::::::::::::


::::::::::::::::::::::::::: spoiler

### How does {cfr} works?

To adjust the CFR, [Nishiura et al., 2009](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0006852) use the case and death incidence data to estimate the number of cases with known outcomes:

$$
  u_t = \dfrac{\sum_{i = 0}^t
        \sum_{j = 0}^\infty c_{i - j} f_{j}}{\sum_{i = 0} c_i},
$$

where:

- $c_{t}$ is the daily case incidence at time $t$, 
- $f_{t}$ is the value of the Probability Mass Function (PMF) of the **delay distribution** between onset and death, and
- $u_{t}$ represents the underestimation factor of the known outcomes.

$u_{t}$ is used to **scale** the value of the cumulative number of cases in the denominator in the calculation of the CFR. This is calculated internally with the [`estimate_outcomes()`](https://epiverse-trace.github.io/cfr/reference/estimate_outcomes.html) function.

The estimator for CFR can be written as: 

$$p_{t} = \frac{b_{t}}{u_{t}}$$

where $p_{t}$ is the realized proportion of confirmed cases to die from the infection (or the unbiased CFR), and $b_{t}$, the crude and biased estimate of CFR (also naive CFR).

From this last equation, we observe that the unbiased CFR $p_{t}$ is larger than biased CFR $b_{t}$ because in $u_{t}$ the numerator is smaller than the denominator (note that $f_{t}$ is the probability distribution of the *delay distribution* between onset and death). Therefore, we refer to $b_{t}$ as the biased estimator of CFR.

When we observe the entire course of an epidemic (from $t \rightarrow \infty$), $u_{t}$ tends to 1, making $b_{t}$ tends to $p_{t}$ and become an unbiased estimator ([Nishiura et al., 2009](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0006852)).

:::::::::::::::::::::::::::


## An early-stage CFR estimate

On the challenge above, we discovered that the _naive_ and _delay-adjusted_ CFR estimates are different.

The **naive** estimate is useful to get an overall severity estimate of the outbreak (so far). Once the outbreak has ended or has progressed such that more deaths are reported, the estimated CFR is then _closest to_ the 'true' unbiased CFR.

On the other hand, the **delay-adjusted** estimate can assess the severity of an emerging infectious disease *earlier* than the biased or naive CFR, during an epidemic.

We can explore the **early** determination of the _delay-adjusted CFR_ using the `cfr_rolling()` function.

:::::::::::::::::::::: callout

`cfr_rolling()` is a utility function that automatically calculates CFR for each day of the outbreak with the data available up to that day, saving the user time.

::::::::::::::::::::::


``` r
# for all the 73 days in the Ebola dataset
# Calculate the rolling daily naive CFR
rolling_cfr_naive <- cfr::cfr_rolling(data = ebola1976)
```

``` output
`cfr_rolling()` is a convenience function to help understand how additional data influences the overall (static) severity. Use `cfr_time_varying()` instead to estimate severity changes over the course of the outbreak.
```


``` r
# for all the 73 days in the Ebola dataset
# Calculate the rolling daily delay-adjusted CFR
rolling_cfr_adjusted <- cfr::cfr_rolling(
  data = ebola1976,
  delay_density = function(x) density(onset_to_death_ebola, x)
)
```

``` output
`cfr_rolling()` is a convenience function to help understand how additional data influences the overall (static) severity. Use `cfr_time_varying()` instead to estimate severity changes over the course of the outbreak.
```

``` output
Some daily ratios of total deaths to total cases with known outcome are below 0.01%: some CFR estimates may be unreliable.FALSE
```

With `utils::tail()`, we show that the latest CFR estimates. The naive and delay-adjusted estimates have overlapping ranges of 95% confidence intervals.


``` r
# Print the tail of the data frame
utils::tail(rolling_cfr_naive)
utils::tail(rolling_cfr_adjusted)
```

Now, let's visualise both results in a time series. How would the naive and delay-adjusted CFR estimates perform in real time?


``` r
# bind by rows both output data frames
dplyr::bind_rows(
  rolling_cfr_naive %>%
    dplyr::mutate(method = "naive"),
  rolling_cfr_adjusted %>%
    dplyr::mutate(method = "adjusted")
) %>%
  # visualise both adjusted and unadjusted rolling estimates
  ggplot() +
  geom_ribbon(
    aes(
      date,
      ymin = severity_low,
      ymax = severity_high,
      fill = method
    ),
    alpha = 0.2, show.legend = FALSE
  ) +
  geom_line(
    aes(date, severity_estimate, colour = method)
  )
```

<img src="fig/severity-static-rendered-unnamed-chunk-20-1.png" style="display: block; margin: auto;" />

The horizontal line represents the delay-adjusted CFR estimated at the outbreak's end. The dotted line means the estimate has a 95% confidence interval (95% CI).

**Notice** that this delay-adjusted calculation is particularly useful when an _epidemic curve of confirmed cases_ is the only data available (i.e. when individual data from onset to death are unavailable, especially during the early stage of the epidemic). When there are few deaths or none at all, an assumption has to be made for the *delay distribution* from onset to death, e.g. from literature based on previous outbreaks. [Nishiura et al., 2009](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0006852) depict this in the figures with data from the SARS outbreak in Hong Kong, 2003.

:::::::::::::::::::::::::::::::::: spoiler

### Case study: SARS outbreak, Hong Kong, 2003

Figures A and B show the cumulative numbers of cases and deaths of SARS, and Figure C shows the observed (biased) CFR estimates as a function of time, i.e. the cumulative number of deaths over cases at time $t$. Due to the delay from the onset of symptoms to death, the biased estimate of CFR at time $t$ underestimates the realised CFR at the end of an outbreak (i.e. 302/1755 = 17.2 %). 

![Observed (biased) confirmed case fatality risk of severe acute respiratory syndrome (SARS) in Hong Kong, 2003. ([Nishiura et al., 2009](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0006852))](fig/cfr-pone.0006852.g003-fig_abc.png)

Nevertheless, even by only using the observed data for the period March 19 to April 2, `cfr_static()` can yield an appropriate prediction (Figure D), e.g. the delay-adjusted CFR at March 27 is 18.1 % (95% CI: 10.5, 28.1). An overestimation is seen in the very early stages of the epidemic, but the 95% confidence limits in the later stages include the realised CFR (i.e. 17.2 %).

![Early determination of the delay-adjusted confirmed case fatality risk of severe acute respiratory syndrome (SARS) in Hong Kong, 2003. ([Nishiura et al., 2009](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0006852))](fig/cfr-pone.0006852.g003-fig_d.png)

::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::: discussion

### Interpret the early-stage CFR estimate

Based on the figure above:

- How much difference in days is between the date in which the 95% CI of the estimated _delay-adjusted CFR_ vs _naive CFR_ cross with the CFR estimated at the end of the outbreak?

Discuss:

- What are the Public health policy implications of having a _delay-adjusted CFR_ estimate?

:::::::::::::::::::::::::::::::::::::::::::: 

:::::::::::::::::::::: hint

We can use either visual inspection or analysis of the output data frames.

::::::::::::::::::::::

:::::::::::::::::::::: solution

There is almost one month of difference.

Note that the estimate has considerable uncertainty at the beginning of the time series. After two weeks, the delay-adjusted CFR approaches the overall CFR estimate at the outbreak's end.

Is this pattern similar to other outbreaks? We can use the data sets in this episode's challenges. We invite you to find it out!

::::::::::::::::::::::

:::::::::::::::::::::: discussion

### Checklist

With `{cfr}`, we estimate the CFR as the proportion of deaths among **confirmed** cases. 

By only using **confirmed** cases, it is clear that all cases that do not seek medical treatment or are not notified will be missed, as well as all asymptomatic cases. This means that the CFR estimate is higher than the proportion of deaths among the infected.

::::::::::::::::::::::

::::::::::::::::::::::::::: solution

### Why the naive and delay-adjusted differ?

`{cfr}` method aims to obtain an unbiased estimator "well before" observing the entire course of the outbreak. For this, `{cfr}` uses the underestimation factor $u_{t}$ to estimate the unbiased CFR $p_{t}$ using maximum-likelihood methods, given the *sampling process* defined by [Nishiura et al., 2009](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0006852).

:::::::::::::::::::::::::::

:::::::::::::::::::::::::: solution

### What is the sampling process?

![The population of confirmed cases and sampling process for estimating the unbiased CFR during the course of an outbreak. ([Nishiura et al., 2009](https://doi.org/10.1371/journal.pone.0006852.g001))](fig/cfr-pone.0006852.g001.png)

From *aggregated incidence data*, at time $t$ we know the cumulative number of confirmed cases and deaths, $C_{t}$ and $D_{t}$, and wish to estimate the unbiased CFR $\pi$, by way of the factor of underestimation $u_{t}$. 

If we knew the factor of underestimation $u_{t}$ we could specify the size of the population of confirmed cases no longer at risk ($u_{t}C_{t}$, **shaded**), although we do not know which surviving individuals belong to this group. A proportion $\pi$ of those in the group of cases still at risk (size $(1- u_{t})C_{t}$, **unshaded**) is expected to die.

Because each case no longer at risk had an independent probability of dying, $\pi$, the number of deaths, $D_{t}$, is a sample from a binomial distribution with sample size $u_{t}C_{t}$, and probability of dying $p_{t}$ = $\pi$.

This is represented by the following likelihood function to obtain the maximum likelihood estimate of the unbiased CFR $p_{t}$ = $\pi$:

$$
  {\sf L}(\pi | C_{t},D_{t},u_{t}) = \log{\dbinom{u_{t}C_{t}}{D_{t}}} + D_{t} \log{\pi} +
  (u_{t}C_{t} - D_{t})\log{(1 - \pi)},
$$

This estimation is performed by the internal function `?cfr:::estimate_severity()`.

::::::::::::::::::::::::::

:::::::::::::::::::::::::: solution

### Limitations

- The delay-adjusted CFR does not address all sources of error in data like the underdiagnosis of infected individuals.

::::::::::::::::::::::::::

## Challenges

:::::::::::::::::::::::::::::::: discussion

### More severity measures

Suppose we need to assess the clinical severity of the epidemic in a context different from surveillance data, like the severity among cases that arrive at hospitals or cases you collected from a representative serological survey. 

Using `{cfr}`, we can change the inputs for the numerator (`cases`) and denominator (`deaths`) to estimate more severity measures like the Infection fatality risk (IFR) or the Hospitalisation Fatality Risk (HFR). We can follow this analogy: 

:::::::::::::::::::::::::::::::: 

:::::::::::::::::::::::::::: solution

### Infection and Hospitalization fatality risk

If for a _Case_ fatality risk (CFR), we require: 

- _case_ and death incidence data, with a 
- case-to-death delay distribution (or close approximation, such as symptom onset-to-death).

Then, the _Infection_ fatality risk (IFR) requires: 

- _infection_ and death incidence data, with an 
- exposure-to-death delay distribution (or close approximation).

Similarly, the _Hospitalisation_ Fatality Risk (HFR) requires: 

- _hospitalisation_ and death incidence data, and a
- hospitalisation-to-death delay distribution.

::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::: solution

### Data sources for more severity measures

[Yang et al., 2020](https://www.nature.com/articles/s41467-020-19238-2/figures/1) summarises different definitions and data sources:

![Severity levels of infections with SARS-CoV-2 and parameters of interest. Each level is assumed to be a subset of the level below.](fig/cfr-s41467-020-19238-2-fig_a.png)

- sCFR symptomatic case-fatality risk, 
- sCHR symptomatic case-hospitalisation risk, 
- mCFR medically attended case-fatality risk, 
- mCHR medically attended case-hospitalisation risk, 
- HFR hospitalisation-fatality risk. 

![Schematic diagram of the baseline analyses. Red, blue, and green arrows denote the data flow from laboratory-confirmed cases of passive surveillance, clinically-diagnosed cases, and laboratory-confirmed cases of active screenings.](fig/cfr-s41467-020-19238-2-fig_b.png){alt='Data source of COVID-19 cases in Wuhan: D1) 32,583 laboratory-confirmed COVID-19 cases as of March 84, D2) 17,365 clinically-diagnosed COVID-19 cases during February 9–194, D3)daily number of laboratory-confirmed cases on March 9–April 243, D4) total number of COVID-19 deaths as of April 24 obtained from the Hubei Health Commission3, D5) 325 laboratory-confirmed cases and D6) 1290 deaths were added as of April 16 through a comprehensive and systematic verification by Wuhan Authorities3, and D7) 16,781 laboratory-confirmed cases identified through universal screening10,11. Pse: RT-PCR sensitivity12. Pmed.care: proportion of seeking medical assistance among patients suffering from acute respiratory infections13.'}

::::::::::::::::::::::::::::

::::::::::::::::: callout

### Aggregated data differ from linelists

*Aggregated* incidence data differs from **linelist** data, where each observation contains individual-level data.


``` r
outbreaks::ebola_sierraleone_2014 %>% as_tibble()
```

``` output
# A tibble: 11,903 × 8
      id   age sex   status    date_of_onset date_of_sample district chiefdom   
   <int> <dbl> <fct> <fct>     <date>        <date>         <fct>    <fct>      
 1     1    20 F     confirmed 2014-05-18    2014-05-23     Kailahun Kissi Teng 
 2     2    42 F     confirmed 2014-05-20    2014-05-25     Kailahun Kissi Teng 
 3     3    45 F     confirmed 2014-05-20    2014-05-25     Kailahun Kissi Tonge
 4     4    15 F     confirmed 2014-05-21    2014-05-26     Kailahun Kissi Teng 
 5     5    19 F     confirmed 2014-05-21    2014-05-26     Kailahun Kissi Teng 
 6     6    55 F     confirmed 2014-05-21    2014-05-26     Kailahun Kissi Teng 
 7     7    50 F     confirmed 2014-05-21    2014-05-26     Kailahun Kissi Teng 
 8     8     8 F     confirmed 2014-05-22    2014-05-27     Kailahun Kissi Teng 
 9     9    54 F     confirmed 2014-05-22    2014-05-27     Kailahun Kissi Teng 
10    10    57 F     confirmed 2014-05-22    2014-05-27     Kailahun Kissi Teng 
# ℹ 11,893 more rows
```

:::::::::::::::::

:::::::::::::::::::::::::::::::::: challenge

### Use incidence2 to rearrange your data

From the `{outbreaks}` package, load the MERS linelist of cases from the `mers_korea_2015` object.

Rearrange your this linelist to fit into the `{cfr}` package input.

Estimate the delay-adjusted HFR using the corresponding distribution delay.

::::::::::::::::: hint

**How to rearrange my input data?**

Rearranging the input data for data analysis can take most of the time. To get ready-to-analyse _aggregated incidence data_, we encourage you to use `{incidence2}`!

First, in the [Get started](https://www.reconverse.org/incidence2/articles/incidence2.html) vignette from the `{incidence2}` package, explore how to use the `date_index` argument when reading a linelist with dates in multiple column.

Then, refer to the `{cfr}` vignette on [Handling data from `{incidence2}`](https://epiverse-trace.github.io/cfr/articles/data_from_incidence2.html) on how to use the `cfr::prepare_data()` function from incidence2 objects.

<!-- cite howto entry one lineslist + incidence2 + cfr connection -->

:::::::::::::::::

::::::::::::::::: solution


``` r
# Load packages
library(cfr)
library(epiparameter)
library(incidence2)
library(outbreaks)
library(tidyverse)

# Access delay distribution
mers_delay <-
  epiparameter::epiparameter_db(
    disease = "mers",
    epi_name = "onset to death",
    single_epiparameter = TRUE
  )

# Read linelist
mers_korea_2015$linelist %>%
  as_tibble() %>%
  select(starts_with("dt_"))
```

``` output
# A tibble: 162 × 6
   dt_onset   dt_report  dt_start_exp dt_end_exp dt_diag    dt_death  
   <date>     <date>     <date>       <date>     <date>     <date>    
 1 2015-05-11 2015-05-19 2015-04-18   2015-05-04 2015-05-20 NA        
 2 2015-05-18 2015-05-20 2015-05-15   2015-05-20 2015-05-20 NA        
 3 2015-05-20 2015-05-20 2015-05-16   2015-05-16 2015-05-21 2015-06-04
 4 2015-05-25 2015-05-26 2015-05-16   2015-05-20 2015-05-26 NA        
 5 2015-05-25 2015-05-27 2015-05-17   2015-05-17 2015-05-26 NA        
 6 2015-05-24 2015-05-28 2015-05-15   2015-05-17 2015-05-28 2015-06-01
 7 2015-05-21 2015-05-28 2015-05-16   2015-05-17 2015-05-28 NA        
 8 2015-05-26 2015-05-29 2015-05-15   2015-05-15 2015-05-29 NA        
 9 NA         2015-05-29 2015-05-15   2015-05-17 2015-05-29 NA        
10 2015-05-21 2015-05-29 2015-05-16   2015-05-16 2015-05-29 NA        
# ℹ 152 more rows
```

``` r
# Use {incidence2} to count daily incidence
mers_incidence <- mers_korea_2015$linelist %>%
  # converto to incidence2 object
  incidence(date_index = c("dt_onset", "dt_death")) %>%
  # complete dates from first to last
  incidence2::complete_dates()

# Inspect incidence2 output
mers_incidence
```

``` output
# incidence:  72 x 3
# count vars: dt_death, dt_onset
   date_index count_variable count
   <date>     <chr>          <int>
 1 2015-05-11 dt_death           0
 2 2015-05-11 dt_onset           1
 3 2015-05-12 dt_death           0
 4 2015-05-12 dt_onset           0
 5 2015-05-13 dt_death           0
 6 2015-05-13 dt_onset           0
 7 2015-05-14 dt_death           0
 8 2015-05-14 dt_onset           0
 9 2015-05-15 dt_death           0
10 2015-05-15 dt_onset           0
# ℹ 62 more rows
```

``` r
# Prepare data from {incidence2} to {cfr}
mers_incidence %>%
  prepare_data(
    cases_variable = "dt_onset",
    deaths_variable = "dt_death"
  )
```

``` output
         date deaths cases
1  2015-05-11      0     1
2  2015-05-12      0     0
3  2015-05-13      0     0
4  2015-05-14      0     0
5  2015-05-15      0     0
6  2015-05-16      0     0
7  2015-05-17      0     1
8  2015-05-18      0     1
9  2015-05-19      0     0
10 2015-05-20      0     5
11 2015-05-21      0     6
12 2015-05-22      0     2
13 2015-05-23      0     4
14 2015-05-24      0     2
15 2015-05-25      0     3
16 2015-05-26      0     1
17 2015-05-27      0     2
18 2015-05-28      0     1
19 2015-05-29      0     3
20 2015-05-30      0     5
21 2015-05-31      0    10
22 2015-06-01      2    16
23 2015-06-02      0    11
24 2015-06-03      1     7
25 2015-06-04      1    12
26 2015-06-05      1     9
27 2015-06-06      0     7
28 2015-06-07      0     7
29 2015-06-08      2     6
30 2015-06-09      0     1
31 2015-06-10      2     6
32 2015-06-11      1     3
33 2015-06-12      0     0
34 2015-06-13      0     2
35 2015-06-14      0     0
36 2015-06-15      0     1
```

``` r
# Estimate delay-adjusted CFR
mers_incidence %>%
  cfr::prepare_data(
    cases_variable = "dt_onset",
    deaths_variable = "dt_death"
  ) %>%
  cfr::cfr_static(delay_density = function(x) density(mers_delay, x))
```

``` output
  severity_estimate severity_low severity_high
1            0.1377       0.0716        0.2288
```



:::::::::::::::::

::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::: challenge

### Severity heterogeneity

The CFR may differ across populations (e.g. age, space, treatment); quantifying these heterogeneities can help target resources appropriately and compare different care regimens ([Cori et al., 2017](https://royalsocietypublishing.org/doi/10.1098/rstb.2016.0371)). 

Use the `cfr::covid_data` data frame to estimate a delay-adjusted CFR stratified by country.

::::::::::::::::::::::::: hint

One way to do a _stratified analysis_ is to apply a model to nested data. This [`{tidyr}` vignette](https://tidyr.tidyverse.org/articles/nest.html#nested-data-and-models) shows you how to apply the `group_by()` + `nest()` to nest data, and then `mutate()` + `map()` to apply the model.

:::::::::::::::::::::::::

::::::::::::::::::::::::: solution


``` r
library(cfr)
library(epiparameter)
library(tidyverse)

covid_data %>% glimpse()
```

``` output
Rows: 20,786
Columns: 4
$ date    <date> 2020-01-03, 2020-01-03, 2020-01-03, 2020-01-03, 2020-01-03, 2…
$ country <chr> "Argentina", "Brazil", "Colombia", "France", "Germany", "India…
$ cases   <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
$ deaths  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
```

``` r
delay_onset_death <-
  epiparameter::epiparameter_db(
    disease = "covid",
    epi_name = "onset to death",
    single_epiparameter = TRUE
  )

covid_data %>%
  group_by(country) %>%
  nest() %>%
  mutate(
    temp =
      map(
        .x = data,
        .f = cfr::cfr_static,
        delay_density = function(x) density(delay_onset_death, x)
      )
  ) %>%
  unnest(cols = temp)
```

``` output
# A tibble: 19 × 5
# Groups:   country [19]
   country        data     severity_estimate severity_low severity_high
   <chr>          <list>               <dbl>        <dbl>         <dbl>
 1 Argentina      <tibble>            0.0133       0.0133        0.0133
 2 Brazil         <tibble>            0.0195       0.0195        0.0195
 3 Colombia       <tibble>            0.0225       0.0224        0.0226
 4 France         <tibble>            0.0044       0.0044        0.0044
 5 Germany        <tibble>            0.0045       0.0045        0.0045
 6 India          <tibble>            0.0119       0.0119        0.0119
 7 Indonesia      <tibble>            0.024        0.0239        0.0241
 8 Iran           <tibble>            0.0191       0.0191        0.0192
 9 Italy          <tibble>            0.0075       0.0075        0.0075
10 Mexico         <tibble>            0.0461       0.046         0.0462
11 Peru           <tibble>            0.0502       0.0501        0.0504
12 Poland         <tibble>            0.0186       0.0186        0.0187
13 Russia         <tibble>            0.0182       0.0182        0.0182
14 South Africa   <tibble>            0.0254       0.0253        0.0255
15 Spain          <tibble>            0.0087       0.0087        0.0087
16 Turkey         <tibble>            0.006        0.006         0.006 
17 Ukraine        <tibble>            0.0204       0.0203        0.0205
18 United Kingdom <tibble>            0.009        0.009         0.009 
19 United States  <tibble>            0.0111       0.0111        0.0111
```

Great! Now you can use similar code for any other stratified analysis like age, regions or more!

But, how can we interpret that there is a country variability of severity from the same diagnosed pathogen?

Local factors like testing capacity, the case definition, and sampling regime can affect the report of cases and deaths, thus affecting case ascertainment. Take a look to the `{cfr}` vignette on [Estimating the proportion of cases that are ascertained during an outbreak](https://epiverse-trace.github.io/cfr/articles/estimate_ascertainment.html)!

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::


## Appendix

The `{cfr}` package has a function called `cfr_time_varying()` with functionality that differs from `cfr_rolling()`.

::::::::::::::::: callout

### When to use cfr_rolling()?

`cfr_rolling()` shows the estimated CFR on each outbreak day, given that future data on cases and deaths is unavailable at the time. The final value of `cfr_rolling()` estimates is identical to `cfr_static()` on the same data.

Remember, as shown above, `cfr_rolling()` is helpful to get early-stage CFR estimates and check whether an outbreak's CFR estimate has stabilised. Thus, `cfr_rolling()` is not sensitive to the length or size of the epidemic.

:::::::::::::::::

::::::::::::::::: callout

### When to use `cfr_time_varying()`?

On the other hand, `cfr_time_varying()` calculates the CFR over a moving window and helps to understand changes in CFR due to changes in the epidemic, e.g. due to a new variant or increased immunity from vaccination.

However, `cfr_time_varying()` is sensitive to sampling uncertainty. Thus, it is sensitive to the size of the outbreak. The higher the number of cases with expected outcomes on a given day, the more reasonable estimates of the time-varying CFR we will get. 

For example, with 100 cases, the fatality risk estimate will, roughly speaking, have a 95% confidence interval ±10% of the mean estimate (binomial CI). So if we have >100 cases with expected outcomes *on a given day*, we can get reasonable estimates of the time varying CFR. But if we only have >100 cases *over the course of the whole epidemic*, we probably need to rely on `cfr_rolling()` that uses the cumulative data.

We invite you to read this [vignette about the `cfr_time_varying()` function](https://epiverse-trace.github.io/cfr/articles/estimate_time_varying_severity.html).

:::::::::::::::::


::::::::::::::::::::::::::::::::::::: keypoints 

- Use `{cfr}` to estimate severity

- Use `cfr_static()` to estimate the overall CFR with the latest data available.

- Use `cfr_rolling()` to show what the estimated CFR would be on each day of the outbreak.

- Use the `delay_density` argument to adjust the CFR by the corresponding delay distribution.

::::::::::::::::::::::::::::::::::::::::::::::::

