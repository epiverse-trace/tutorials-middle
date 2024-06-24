---
title: 'Quantifying transmission'
teaching: 30
exercises: 0
---

:::::::::::::::::::::::::::::::::::::: questions 

- How can I estimate the time-varying reproduction number ($Rt$) and growth rate from a time series of case data?
- How can I quantify geographical heterogeneity from these transmission metrics? 


::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Learn how to estimate transmission metrics from a time series of case data using the R package `EpiNow2`

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: prereq

## Prerequisites

Learners should familiarise themselves with following concepts before working through this tutorial: 

**Statistics**: probability distributions, principle of Bayesian analysis. 

**Epidemic theory**: Effective reproduction number.

**Data science**: Data transformation and visualization. You can review the episode on [Aggregate and visualize](https://epiverse-trace.github.io/tutorials-early/describe-cases.html) incidence data.

:::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::: callout
### Reminder: the Effective Reproduction Number, $R_t$ 

The [basic reproduction number](../learners/reference.md#basic), $R_0$, is the average number of cases caused by one infectious individual in a entirely susceptible population. 

But in an ongoing outbreak, the population does not remain entirely susceptible as those that recover from infection are typically immune. Moreover, there can be changes in behaviour or other factors that affect transmission. When we are interested in monitoring changes in transmission we are therefore more interested in the value of the **effective reproduction number**, $R_t$, the average number of cases caused by one infectious individual in the population at time $t$.

::::::::::::::::::::::::::::::::::::::::::::::::


## Introduction

The transmission intensity of an outbreak is quantified using two key metrics: the reproduction number, which informs on the strength of the transmission by indicating how many new cases are expected from each existing case; and the [growth rate](../learners/reference.md#growth), which informs on the speed of the transmission by indicating how rapidly the outbreak is spreading or declining (doubling/halving time) within a population. For more details on the distinction between speed and strength of transmission and implications for control, review [Dushoff & Park, 2021](https://royalsocietypublishing.org/doi/full/10.1098/rspb.2020.1556).

To estimate these key metrics using case data we must account for delays between the date of infections and date of reported cases. In an outbreak situation, data are usually available on reported dates only, therefore we must use estimation methods to account for these delays when trying to understand changes in transmission over time.

In the next tutorials we will focus on how to use the functions in `{EpiNow2}` to estimate transmission metrics of case data. We will not cover the theoretical background of the models or inference framework, for details on these concepts see the [vignette](https://epiforecasts.io/EpiNow2/dev/articles/estimate_infections.html).

In this tutorial we are going to learn how to use the `{EpiNow2}` package to estimate the time-varying reproduction number. We'll get input data from `{incidence2}`. We’ll use the `{tidyr}` and `{dplyr}` packages to arrange some of its outputs, `{ggplot2}` to visualize case distribution, and the pipe `%>%` to connect some of their functions, so let’s also call to the `{tidyverse}` package:

```r
library(EpiNow2)
library(incidence2)
library(tidyverse)
```




::::::::::::::::::: checklist

### The double-colon

The double-colon `::` in R let you call a specific function from a package without loading the entire package into the current environment. 

For example, `dplyr::filter(data, condition)` uses `filter()` from the `{dplyr}` package.

This help us remember package functions and avoid namespace conflicts.

:::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: instructor

This tutorial illustrates the usage of `epinow()` to estimate the time-varying reproduction number and infection times. Learners should understand the necessary inputs to the model and the limitations of the model output. 

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::::::::::::::::::::::::::::::::::::: callout
### Bayesian inference

The R package `EpiNow2` uses a [Bayesian inference](../learners/reference.md#bayesian) framework to estimate reproduction numbers and infection times based on reporting dates.

In Bayesian inference, we use prior knowledge (prior distributions) with data (in a likelihood function) to find the posterior probability.

<p class="text-center" style="background-color: white">Posterior probability $\propto$ likelihood $\times$ prior probability
</p>

::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::: instructor

Refer to the prior probability distribution and the [posterior probability](https://en.wikipedia.org/wiki/Posterior_probability) distribution.

In the ["`Expected change in daily cases`" callout](#expected-change-in-daily-cases), by "the posterior probability that $R_t < 1$", we refer specifically to the [area under the posterior probability distribution curve](https://www.nature.com/articles/nmeth.3368/figures/1). 

::::::::::::::::::::::::::::::::::::::::::::::::


## Delay distributions and case data 
### Case data

To illustrate the functions of `EpiNow2` we will use outbreak data of the start of the COVID-19 pandemic from the United Kingdom. The data are available in the R package `{incidence2}`. 


``` r
dplyr::as_tibble(incidence2::covidregionaldataUK)
```

``` output
# A tibble: 6,370 × 13
   date       region   region_code cases_new cases_total deaths_new deaths_total
   <date>     <chr>    <chr>           <dbl>       <dbl>      <dbl>        <dbl>
 1 2020-01-30 East Mi… E12000004          NA          NA         NA           NA
 2 2020-01-30 East of… E12000006          NA          NA         NA           NA
 3 2020-01-30 England  E92000001           2           2         NA           NA
 4 2020-01-30 London   E12000007          NA          NA         NA           NA
 5 2020-01-30 North E… E12000001          NA          NA         NA           NA
 6 2020-01-30 North W… E12000002          NA          NA         NA           NA
 7 2020-01-30 Norther… N92000002          NA          NA         NA           NA
 8 2020-01-30 Scotland S92000003          NA          NA         NA           NA
 9 2020-01-30 South E… E12000008          NA          NA         NA           NA
10 2020-01-30 South W… E12000009          NA          NA         NA           NA
# ℹ 6,360 more rows
# ℹ 6 more variables: recovered_new <dbl>, recovered_total <dbl>,
#   hosp_new <dbl>, hosp_total <dbl>, tested_new <dbl>, tested_total <dbl>
```

To use the data, we must format the data to have two columns:

+ `date`: the date (as a date object see `?is.Date()`),
+ `confirm`: number of confirmed cases on that date.

Let's use `{tidyr}` and `{incidence2}` for this:


``` r
cases <- incidence2::covidregionaldataUK %>%
  # use {tidyr} to preprocess missing values
  tidyr::replace_na(base::list(cases_new = 0)) %>%
  # use {incidence2} to compute the daily incidence
  incidence2::incidence(
    date_index = "date",
    counts = "cases_new",
    count_values_to = "confirm",
    date_names_to = "date",
    complete_dates = TRUE
  ) %>%
  dplyr::select(-count_variable)
```

With `incidence2::incidence()` we aggregate cases in different time *intervals* (i.e., days, weeks or months) or per *group* categories. Also we can have complete dates for all the range of dates per group category using `complete_dates = TRUE`
Explore later the [`incidence2::incidence()` reference manual](https://www.reconverse.org/incidence2/reference/incidence.html)

::::::::::::::::::::::::: spoiler

### Can we replicate {incidence2} with {dplyr}?

We can get an object similar to `cases` from the `incidence2::covidregionaldataUK` data frame using the `{dplyr}` package.


``` r
incidence2::covidregionaldataUK %>%
  dplyr::select(date, cases_new) %>%
  dplyr::group_by(date) %>%
  dplyr::summarise(confirm = sum(cases_new, na.rm = TRUE)) %>%
  dplyr::ungroup()
```

However, the `incidence2::incidence()` function contains convenient arguments like `complete_dates` that facilitate getting an incidence object with the same range of dates for each grouping without the need of extra code lines or a time-series package.

:::::::::::::::::::::::::

There are case data available for 490 days, but in an outbreak situation it is likely we would only have access to the beginning of this data set. Therefore we assume we only have the first 90 days of this data. 

<img src="fig/quantify-transmissibility-rendered-unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

### Delay distributions 

We assume there are delays from the time of infection until the time a case is reported. We specify these delays as distributions to account for the uncertainty in individual level differences. The delay can consist of multiple types of delays/processes. A typical delay from time of infection to case reporting may consist of:

<p class="text-center" style="background-color: aliceblue">**time from infection to symptom onset** (the [incubation period](../learners/reference.md#incubation)) + **time from symptom onset to case notification** (the reporting time)
.</p>

The delay distribution for each of these processes can either estimated from data or obtained from the literature. We can express uncertainty about what the correct parameters of the distributions by assuming the distributions have **fixed** parameters or whether they have **variable** parameters. To understand the difference between **fixed** and **variable** distributions, let's consider the incubation period. 

::::::::::::::::::::::::::::::::::::: callout

### Delays and data
The number of delays and type of delay are a flexible input that depend on the data. The examples below highlight how the delays can be specified for different data sources:

<center>

| Data source        | Delay(s) |
| ------------- |-------------|
|Time of symptom onset      |Incubation period |
|Time of case report      |Incubation period + time from symptom onset to case notification |
|Time of hospitalisation   |Incubation period + time from symptom onset to hospitalisation     |

</center>


::::::::::::::::::::::::::::::::::::::::::::::::



#### Incubation period distribution 

The distribution of incubation period for many diseases can usually be obtained from the literature. The package `{epiparameter}` contains a library of epidemiological parameters for different diseases obtained from the literature. 

We specify a (fixed) gamma distribution with mean $\mu = 4$ and standard deviation $\sigma= 2$ (shape = $4$, scale = $1$) using the function `Gamma()` as follows:


``` r
incubation_period_fixed <- EpiNow2::Gamma(
  mean = 4,
  sd = 2,
  max = 20
)

incubation_period_fixed
```

``` output
- gamma distribution (max: 20):
  shape:
    4
  rate:
    1
```

The argument `max` is the maximum value the distribution can take, in this example 20 days. 

::::::::::::::::::::::::::::::::::::: callout

### Why a gamma distrubution? 

The incubation period has to be positive in value. Therefore we must specific a distribution in `{EpiNow2}` which is for positive values only. 

`Gamma()` supports Gamma distributions and `LogNormal()` Log-normal distributions, which are distributions for positive values only. 

For all types of delay, we will need to use distributions for positive values only - we don't want to include delays of negative days in our analysis!

::::::::::::::::::::::::::::::::::::::::::::::::



####  Including distribution uncertainty

To specify a **variable** distribution, we include uncertainty around the mean $\mu$ and standard deviation $\sigma$ of our gamma distribution. If our incubation period distribution has a mean $\mu$ and standard deviation $\sigma$, then we assume the mean ($\mu$) follows a Normal distribution with standard deviation $\sigma_{\mu}$:

$$\mbox{Normal}(\mu,\sigma_{\mu}^2)$$

and a standard deviation ($\sigma$) follows a Normal distribution with standard deviation $\sigma_{\sigma}$:

$$\mbox{Normal}(\sigma,\sigma_{\sigma}^2).$$

We specify this using `Normal()` for each argument: the mean ($\mu=4$ with $\sigma_{\mu}=0.5$) and standard deviation ($\sigma=2$ with $\sigma_{\sigma}=0.5$).


``` r
incubation_period_variable <- EpiNow2::Gamma(
  mean = EpiNow2::Normal(mean = 4, sd = 0.5),
  sd = EpiNow2::Normal(mean = 2, sd = 0.5),
  max = 20
)

incubation_period_variable
```

``` output
- gamma distribution (max: 20):
  shape:
    - normal distribution:
      mean:
        4
      sd:
        0.61
  rate:
    - normal distribution:
      mean:
        1
      sd:
        0.31
```


####  Reporting delays

After the incubation period, there will be an additional delay of time from symptom onset to case notification: the reporting delay. We can specify this as a fixed or variable distribution, or estimate a distribution from data. 

When specifying a distribution, it is useful to visualise the probability density to see the peak and spread of the distribution, in this case we will use a *log normal* distribution. We can use the functions `convert_to_logmean()` and `convert_to_logsd()` to  convert the mean and standard deviation of a normal distribution to that of a log normal distribution. 

If we want to assume that the mean reporting delay is 2 days (with a standard deviation of 1 day), we write: 


``` r
# convert mean to logmean
log_mean <- EpiNow2::convert_to_logmean(mean = 2, sd = 1)

# convert sd to logsd
log_sd <- EpiNow2::convert_to_logsd(mean = 2, sd = 1)
```

:::::::::::::::::::::: spoiler

### Visualize a log Normal distribution using {epiparameter}

Using `epiparameter::epidist()` we can create a custom distribution. The log normal distribution will look like:

```r
library(epiparameter)
```


``` r
epiparameter::epidist(
  disease = "covid",
  epi_dist = "reporting delay",
  prob_distribution = "lnorm",
  prob_distribution_params = c(
    meanlog = log_mean,
    sdlog = log_sd
  )
) %>%
  plot()
```

<img src="fig/quantify-transmissibility-rendered-unnamed-chunk-9-1.png" style="display: block; margin: auto;" />

::::::::::::::::::::::

Using the mean and standard deviation for the log normal distribution, we can specify a fixed or variable distribution using `LogNormal()` as before: 


``` r
reporting_delay_variable <- EpiNow2::LogNormal(
  meanlog = EpiNow2::Normal(mean = log_mean, sd = 0.5),
  sdlog = EpiNow2::Normal(mean = log_sd, sd = 0.5),
  max = 10
)
```

We can plot single and combined distributions generated by `{EpiNow2}` using `plot()`. Let's combine in one plot the delay from infection to report which includes the incubation period and reporting delay:


``` r
plot(incubation_period_variable + reporting_delay_variable)
```

<img src="fig/quantify-transmissibility-rendered-unnamed-chunk-11-1.png" style="display: block; margin: auto;" />


:::::::::::::::::: callout

If data is available on the time between symptom onset and reporting, we can use the function `estimate_delay()` to estimate a log normal distribution from a vector of delays. The code below illustrates how to use `estimate_delay()` with synthetic delay data. 


``` r
delay_data <- rlnorm(500, log(5), 1) # synthetic delay data

reporting_delay <- EpiNow2::estimate_delay(
  delay_data,
  samples = 1000,
  bootstraps = 10
)
```

::::::::::::::::::

####  Generation time

We also must specify a distribution for the generation time. Here we will use a log normal distribution with mean 3.6 and standard deviation 3.1 ([Ganyani et al. 2020](https://doi.org/10.2807/1560-7917.ES.2020.25.17.2000257)).



``` r
generation_time_variable <- EpiNow2::LogNormal(
  mean = EpiNow2::Normal(mean = 3.6, sd = 0.5),
  sd = EpiNow2::Normal(mean = 3.1, sd = 0.5),
  max = 20
)
```


## Finding estimates

The function `epinow()` is a wrapper for the function `estimate_infections()` used to estimate cases by date of infection. The generation time distribution and delay distributions must be passed using the functions ` generation_time_opts()` and `delay_opts()` respectively. 

There are numerous other inputs that can be passed to `epinow()`, see `?EpiNow2::epinow()` for more detail.
One optional input is to specify a *log normal* prior for the effective reproduction number $R_t$ at the start of the outbreak. We specify a mean of 2 days and standard deviation of 2 days as arguments of `prior` within `rt_opts()`:


``` r
# define Rt prior distribution
rt_prior <- EpiNow2::rt_opts(prior = base::list(mean = 2, sd = 2))
```

::::::::::::::::::::::::::::::::::::: callout

### Bayesian inference using Stan 

The Bayesian inference is performed using MCMC methods with the program [Stan](https://mc-stan.org/). There are a number of default inputs to the Stan functions including the number of chains and number of samples per chain (see `?EpiNow2::stan_opts()`).

To reduce computation time, we can run chains in parallel. To do this, we must set the number of cores to be used. By default, 4 MCMC chains are run (see `stan_opts()$chains`), so we can set an equal number of cores to be used in parallel as follows:


``` r
withr::local_options(base::list(mc.cores = 4))
```

To find the maximum number of available cores on your machine, use `parallel::detectCores()`.

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::: checklist

**Note:** In the code below `_fixed` distributions are used instead of `_variable` (delay distributions with uncertainty). This is to speed up computation time. It is generally recommended to use variable distributions that account for additional uncertainty.


``` r
# fixed alternatives
generation_time_fixed <- EpiNow2::LogNormal(
  mean = 3.6,
  sd = 3.1,
  max = 20
)

reporting_delay_fixed <- EpiNow2::LogNormal(
  mean = log_mean,
  sd = log_sd,
  max = 10
)
```

:::::::::::::::::::::::::

Now you are ready to run `EpiNow2::epinow()` to estimate the time-varying reproduction number for the first 90 days:


``` r
reported_cases <- cases %>%
  dplyr::slice_head(n = 90)
```


``` r
estimates <- EpiNow2::epinow(
  # cases
  data = reported_cases,
  # delays
  generation_time = EpiNow2::generation_time_opts(generation_time_fixed),
  delays = EpiNow2::delay_opts(incubation_period_fixed + reporting_delay_fixed),
  # prior
  rt = rt_prior
)
```

``` output
WARN [2024-06-24 12:08:46] epinow: There were 1 divergent transitions after warmup. See
https://mc-stan.org/misc/warnings.html#divergent-transitions-after-warmup
to find out why this is a problem and how to eliminate them. - 
WARN [2024-06-24 12:08:46] epinow: Examine the pairs() plot to diagnose sampling problems
 - 
```

<!-- ```{r, message = FALSE,warning=FALSE, eval = TRUE, echo=FALSE} -->
<!-- estimates <- EpiNow2::epinow( -->
<!--   # cases -->
<!--   data = reported_cases, -->
<!--   # delays -->
<!--   generation_time = EpiNow2::generation_time_opts(generation_time_fixed), -->
<!--   delays = EpiNow2::delay_opts(incubation_period_fixed + reporting_delay_fixed), -->
<!--   # prior -->
<!--   rt = rt_prior, -->
<!--   stan = EpiNow2::stan_opts(method = "vb") -->
<!-- ) -->
<!-- ``` -->


::::::::::::::::::::::::::::::::: callout

### Do not wait for this to continue

For the purpose of this tutorial, we can optionally use `EpiNow2::stan_opts()` to reduce computation time. We can specify a fixed number of `samples = 1000` and `chains = 2` to the `stan` argument of the `EpiNow2::epinow()` function. We expect this to take approximately 3 minutes.

<!-- We can optionally set `stan = stan_opts(method = "vb")` to use an approximate sampling method. We expect this to take less than 1 minute. -->

```r
# you can add the `stan` argument
EpiNow2::epinow(
  ...,
  stan = EpiNow2::stan_opts(samples = 1000, chains = 2)
)
```

**Remember:** Using an appropriate number of *samples* and *chains* is crucial for ensuring convergence and obtaining reliable estimates in Bayesian computations using Stan. More accurate outputs come at the cost of speed.

:::::::::::::::::::::::::::::::::

### Results

We can extract and visualise estimates of the effective reproduction number through time:


``` r
estimates$plots$R
```

<img src="fig/quantify-transmissibility-rendered-unnamed-chunk-19-1.png" style="display: block; margin: auto;" />

The uncertainty in the estimates increases through time. This is because estimates are informed by data in the past - within the delay periods. This difference in uncertainty is categorised into **Estimate** (green) utilises all data and **Estimate based on partial data** (orange) estimates that are based on less data (because infections that happened at the time are more likely to not have been observed yet) and therefore have increasingly wider intervals towards the date of the last data point. Finally, the **Forecast** (purple) is a projection ahead of time. 

We can also visualise the growth rate estimate through time: 

``` r
estimates$plots$growth_rate
```

<img src="fig/quantify-transmissibility-rendered-unnamed-chunk-20-1.png" style="display: block; margin: auto;" />

To extract a summary of the key transmission metrics at the *latest date* in the data:


``` r
summary(estimates)
```

``` output
                            measure                estimate
                             <char>                  <char>
1:           New infections per day    6825 (3648 -- 12086)
2: Expected change in daily reports       Likely decreasing
3:       Effective reproduction no.      0.87 (0.58 -- 1.2)
4:                   Rate of growth -0.047 (-0.19 -- 0.098)
5:     Doubling/halving time (days)         -15 (7 -- -3.6)
```

As these estimates are based on partial data, they have a wide uncertainty interval.

+ From the summary of our analysis we see that the expected change in daily cases is  with the estimated new confirmed cases .

+ The effective reproduction number $R_t$ estimate (on the last date of the data) is 0.87 (0.58 -- 1.2). 

+ The exponential growth rate of case numbers is -0.047 (-0.19 -- 0.098).

+ The doubling time (the time taken for case numbers to double) is -15 (7 -- -3.6).

::::::::::::::::::::::::::::::::::::: callout
### `Expected change in daily cases` 

A factor describing expected change in daily cases based on the posterior probability that $R_t < 1$.

<center>
| Probability ($p$)      | Expected change |
| ------------- |-------------|
|$p < 0.05$    |Increasing |
|$0.05 \leq p< 0.4$    |Likely increasing |
|$0.4 \leq p< 0.6$    |Stable |
|$0.6 \leq p < 0.95$    |Likely decreasing |
|$0.95 \leq p \leq 1$    |Decreasing |
</center>

::::::::::::::::::::::::::::::::::::::::::::::::




## Quantify geographical heterogeneity

The outbreak data of the start of the COVID-19 pandemic from the United Kingdom from the R package `{incidence2}` includes the region in which the cases were recorded. To find regional estimates of the effective reproduction number and cases, we must format the data to have three columns:

+ `date`: the date,
+ `region`: the region, 
+ `confirm`: number of confirmed cases for a region on a given date.


``` r
regional_cases <- incidence2::covidregionaldataUK %>%
  # use {tidyr} to preprocess missing values
  tidyr::replace_na(base::list(cases_new = 0)) %>%
  # use {incidence2} to convert aggregated data to incidence data
  incidence2::incidence(
    date_index = "date",
    groups = "region",
    counts = "cases_new",
    count_values_to = "confirm",
    date_names_to = "date",
    complete_dates = TRUE
  ) %>%
  dplyr::select(-count_variable)

# keep the first 90 dates for all regions

# get vector of first 90 dates
date_range <- regional_cases %>%
  dplyr::distinct(date) %>%
  # from incidence2, dates are already arranged in ascendant order
  dplyr::slice_head(n = 90) %>%
  dplyr::pull(date)

# filter dates in date_range
regional_cases <- regional_cases %>%
  dplyr::filter(magrittr::is_in(x = date, table = date_range))

dplyr::as_tibble(regional_cases)
```

``` output
# A tibble: 1,170 × 3
   date       region           confirm
   <date>     <chr>              <dbl>
 1 2020-01-30 East Midlands          0
 2 2020-01-30 East of England        0
 3 2020-01-30 England                2
 4 2020-01-30 London                 0
 5 2020-01-30 North East             0
 6 2020-01-30 North West             0
 7 2020-01-30 Northern Ireland       0
 8 2020-01-30 Scotland               0
 9 2020-01-30 South East             0
10 2020-01-30 South West             0
# ℹ 1,160 more rows
```

To find regional estimates, we use the same inputs as `epinow()` to the function `regional_epinow()`:


``` r
estimates_regional <- EpiNow2::regional_epinow(
  # cases
  data = regional_cases,
  # delays
  generation_time = EpiNow2::generation_time_opts(generation_time_fixed),
  delays = EpiNow2::delay_opts(incubation_period_fixed + reporting_delay_fixed),
  # prior
  rt = rt_prior
)
```

``` output
INFO [2024-06-24 12:08:52] Producing following optional outputs: regions, summary, samples, plots, latest
INFO [2024-06-24 12:08:52] Reporting estimates using data up to: 2020-04-28
INFO [2024-06-24 12:08:52] No target directory specified so returning output
INFO [2024-06-24 12:08:52] Producing estimates for: East Midlands, East of England, England, London, North East, North West, Northern Ireland, Scotland, South East, South West, Wales, West Midlands, Yorkshire and The Humber
INFO [2024-06-24 12:08:52] Regions excluded: none
INFO [2024-06-24 13:06:08] Completed regional estimates
INFO [2024-06-24 13:06:08] Regions with estimates: 13
INFO [2024-06-24 13:06:08] Regions with runtime errors: 0
INFO [2024-06-24 13:06:08] Producing summary
INFO [2024-06-24 13:06:08] No summary directory specified so returning summary output
INFO [2024-06-24 13:06:09] No target directory specified so returning timings
```

<!-- ```{r, message = FALSE,warning=FALSE, eval = TRUE,echo=FALSE} -->
<!-- estimates_regional <- EpiNow2::regional_epinow( -->
<!--   # cases -->
<!--   data = regional_cases, -->
<!--   # delays -->
<!--   generation_time = EpiNow2::generation_time_opts(generation_time_fixed), -->
<!--   delays = EpiNow2::delay_opts(incubation_period_fixed + reporting_delay_fixed), -->
<!--   # prior -->
<!--   rt = rt_prior, -->
<!--   stan = EpiNow2::stan_opts(method = "vb") -->
<!-- ) -->
<!-- ``` -->


``` r
estimates_regional$summary$summarised_results$table
```

``` output
                      Region New infections per day
                      <char>                 <char>
 1:            East Midlands       337 (202 -- 536)
 2:          East of England       499 (304 -- 792)
 3:                  England    3411 (2082 -- 5315)
 4:                   London       300 (192 -- 455)
 5:               North East       249 (138 -- 420)
 6:               North West       542 (323 -- 857)
 7:         Northern Ireland          43 (21 -- 89)
 8:                 Scotland       282 (136 -- 567)
 9:               South East       593 (361 -- 965)
10:               South West       426 (306 -- 586)
11:                    Wales         94 (62 -- 136)
12:            West Midlands       233 (122 -- 421)
13: Yorkshire and The Humber       457 (280 -- 730)
    Expected change in daily reports Effective reproduction no.
                              <fctr>                     <char>
 1:                Likely increasing          1.1 (0.81 -- 1.4)
 2:                           Stable            1 (0.77 -- 1.3)
 3:                Likely decreasing          0.9 (0.66 -- 1.2)
 4:                Likely decreasing         0.89 (0.68 -- 1.1)
 5:                Likely decreasing         0.92 (0.64 -- 1.2)
 6:                Likely decreasing         0.88 (0.64 -- 1.1)
 7:                Likely decreasing         0.77 (0.49 -- 1.2)
 8:                Likely decreasing         0.95 (0.61 -- 1.4)
 9:                           Stable         0.98 (0.73 -- 1.3)
10:                       Increasing             1.3 (1 -- 1.5)
11:                       Decreasing        0.71 (0.55 -- 0.89)
12:                       Decreasing           0.69 (0.44 -- 1)
13:                Likely decreasing          0.95 (0.7 -- 1.2)
               Rate of growth Doubling/halving time (days)
                       <char>                       <char>
 1:    0.022 (-0.085 -- 0.11)             31 (6.1 -- -8.2)
 2:     0.0031 (-0.11 -- 0.1)            220 (6.9 -- -6.2)
 3:   -0.038 (-0.15 -- 0.066)             -18 (11 -- -4.6)
 4:   -0.031 (-0.13 -- 0.051)             -22 (14 -- -5.3)
 5:   -0.025 (-0.15 -- 0.083)            -28 (8.3 -- -4.7)
 6:   -0.041 (-0.15 -- 0.052)             -17 (13 -- -4.7)
 7:    -0.064 (-0.21 -- 0.11)            -11 (6.3 -- -3.4)
 8:    -0.012 (-0.16 -- 0.15)            -57 (4.5 -- -4.4)
 9:   -0.0072 (-0.12 -- 0.11)            -97 (6.3 -- -5.7)
10:   0.075 (-0.0015 -- 0.15)            9.3 (4.5 -- -470)
11: -0.089 (-0.17 -- -0.0091)             -7.8 (-76 -- -4)
12:    -0.11 (-0.26 -- 0.027)            -6.1 (26 -- -2.7)
13:   -0.025 (-0.14 -- 0.077)                -28 (9 -- -5)
```

``` r
estimates_regional$summary$plots$R
```

<img src="fig/quantify-transmissibility-rendered-unnamed-chunk-24-1.png" style="display: block; margin: auto;" />


<!-- :::::::::::::::::::::::::: testimonial -->

<!-- ### the i2extras package -->

<!-- `{i2extras}` package also estimate transmission metrics like growth rate and doubling/halving time at different time intervals (i.e., days, weeks, or months). `{i2extras}` require `{incidence2}` objects as inputs. Read further in its [Fitting curves](https://www.reconverse.org/i2extras/articles/fitting_epicurves.html) vignette. -->

<!-- :::::::::::::::::::::::::: -->

## Summary

`EpiNow2` can be used to estimate transmission metrics from case data at any time in the course of an outbreak. The reliability of these estimates depends on the quality of the data and appropriate choice of delay distributions. In the next tutorial we will learn how to make forecasts and investigate some of the additional inference options available in `EpiNow2`. 

::::::::::::::::::::::::::::::::::::: keypoints 

- Transmission metrics can be estimated from case data after accounting for delays
- Uncertainty can be accounted for in delay distributions

::::::::::::::::::::::::::::::::::::::::::::::::
