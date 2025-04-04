# Week 2: Access delays to estimate transmission and severity

<!-- visible for instructors only -->
<!-- practical-week.md is generated from practical-week.qmd. Please edit that file -->
<!-- commit .md and .qmd files together -->
<!-- does not work for instructors text messages -->
<!-- works for text on PDF and MD only -->

These practical is based in the following tutorial episodes:

- <https://epiverse-trace.github.io/tutorials-middle/delays-access.html>
- <https://epiverse-trace.github.io/tutorials-middle/quantify-transmissibility.html>
- <https://epiverse-trace.github.io/tutorials-middle/delays-functions.html>
- <https://epiverse-trace.github.io/tutorials-middle/severity-static.html>

Welcome!

- A reminder of our Code of Conduct:
- <https://github.com/epiverse-trace/.github/blob/main/CODE_OF_CONDUCT.md>
- If you experience or witness unacceptable behaviour, or have any other
  concerns, please report by email or online form available at the “How
  to report a violation” section.
- To report an issue involving one of the organisers, please use the
  LSHTM’s Report and Support tool, where your concern will be triaged by
  a member of LSHTM’s Equity and Diversity Team.
- <https://reportandsupport.lshtm.ac.uk/>

Roll call:

- Group 1: …, …
- Group 2: …, …
- Group 3: …, …
- Group 4: …, …

# Practical

<!-- visible for learners and instructors at practical -->

This practical has two activities.

Before your start, as a group:

- Create one copy of the Posit Cloud project `<paste link>`.
- Solve each challenge using the `Code chunk` as a guide.
- Paste your figure and table outputs.
- Write your answer to the questions.
- Choose one person from your group to share your results with everyone.

During the practical, instead of copy-paste, we encourage learners to
increase their fluency writing R by using:

- Tab key <kbd>↹</kbd> for [code completion
  feature](https://support.posit.co/hc/en-us/articles/205273297-Code-Completion-in-the-RStudio-IDE)
  and [possible arguments
  displayed](https://docs.posit.co/ide/user/ide/guide/code/console.html).
- The double-colon `package::function()` notation. This helps us
  remember package functions and avoid namespace conflicts.
- [R
  shortcuts](https://positron.posit.co/keyboard-shortcuts.html#r-shortcuts):
  - `Cmd/Ctrl`+`Shift`+`M` to Insert the pipe operator (`|>` or `%>%`)
  - `Alt`+`-` to Insert the assignment operator (`<-`)
- The `help()` function or `?` operator to access function reference
  manual.

# Paste your !Error messages here






## Activity 1: Transmission

Estimate $R_{t}$, *new infections*, *new reports*, *growth rate*, and
*doubling/halving time* using the following available inputs:

- Incidence of reported cases per day
- Reporting delay

As a group, Write your answer to these questions:

- What phase of the epidemic are you observing? (Exponential growth
  phase, near peak, or decay end phase)
- Is the expected change in daily reports consistent with the estimated
  effective reproductive number, growth rate, and doubling time?
- Interpret: How would you communicate these results to a
  decision-maker?
- Compare: What differences you identify from other group outputs? (if
  available)

### Inputs

| Group | Incidence     | Link                                                                      |
|-------|---------------|---------------------------------------------------------------------------|
| 1     | COVID 30 days | <https://epiverse-trace.github.io/tutorials-middle/data/covid_30days.rds> |
| 2     | Ebola 35 days | <https://epiverse-trace.github.io/tutorials-middle/data/ebola_35days.rds> |
| 3     | Ebola 60 days | <https://epiverse-trace.github.io/tutorials-middle/data/ebola_60days.rds> |
| 4     | COVID 60 days | <https://epiverse-trace.github.io/tutorials-middle/data/covid_60days.rds> |

| Disease | Reporting delays                                                                                                                                                                                                                                                                                            |
|---------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Ebola   | The time difference between symptom onset and case report follows a Lognormal distribution with uncertainty. The **meanlog** follows a Normal distribution with mean = 1.4 and sd = 0.5. The **sdlog** follows a Normal distribution with mean = 0.25 and sd = 0.2. Bound the distribution with max = 5.    |
| COVID   | The time difference between symptom onset and case report follows a Gamma distribution with uncertainty. The **mean** follows a Normal distribution with mean = 2 and sd = 0.5. The **standard deviation** follows a Normal distribution with mean = 1 and sd = 0.5. Bound the distribution with a max = 5. |

### Solution

<!-- visible for instructors and learners after practical (solutions) -->

#### Code

##### Ebola (sample)

``` r
# Load packages -----------------------------------------------------------
library(epiparameter)
library(EpiNow2)
library(tidyverse)

# Read reported cases -----------------------------------------------------
dat_ebola <- readr::read_rds(
  "https://epiverse-trace.github.io/tutorials-middle/data/ebola_35days.rds"
) %>%
  dplyr::select(date, confirm = cases)

# Define a generation time from {epiparameter} to {EpiNow2} ---------------

# access a serial interval
ebola_serialint <- epiparameter::epiparameter_db(
  disease = "ebola",
  epi_name = "serial",
  single_epiparameter = TRUE
)

# extract parameters from {epiparameter} object
ebola_serialint_params <- epiparameter::get_parameters(ebola_serialint)

# adapt {epiparameter} to {EpiNow2} distribution inferfase
# preferred
ebola_generationtime <- EpiNow2::Gamma(
  shape = ebola_serialint_params["shape"],
  scale = ebola_serialint_params["scale"]
)
# or
ebola_generationtime <- EpiNow2::Gamma(
  mean = ebola_serialint$summary_stats$mean,
  sd = ebola_serialint$summary_stats$sd
)


# Define the delays from infection to case report for {EpiNow2} -----------

# define delay from symptom onset to case report
# or reporting delay
ebola_reportdelay <- EpiNow2::LogNormal(
  meanlog = EpiNow2::Normal(mean = 1.4, sd = 0.5),
  sdlog = EpiNow2::Normal(mean = 0.25, sd = 0.2),
  max = 5
)

# define a delay from infection to symptom onset
# or incubation period
ebola_incubationtime <- epiparameter::epiparameter_db(
  disease = "ebola",
  epi_name = "incubation",
  single_epiparameter = TRUE
)

# incubation period: extract distribution parameters
ebola_incubationtime_params <- epiparameter::get_parameters(
  ebola_incubationtime
)

# incubation period: discretize and extract maximum value (p = 99%)
# preferred
ebola_incubationtime_max <- ebola_incubationtime %>%
  epiparameter::discretise() %>%
  quantile(p = 0.99)
# or
ebola_incubationtime_max <- ebola_incubationtime %>%
  quantile(p = 0.99) %>%
  base::round()

# incubation period: adapt to {EpiNow2} distribution interfase
ebola_incubationtime_epinow <- EpiNow2::Gamma(
  shape = ebola_incubationtime_params["shape"],
  scale = ebola_incubationtime_params["scale"],
  max = ebola_incubationtime_max
)

# collect required input
ebola_generationtime
ebola_reportdelay
ebola_incubationtime_epinow


# Set the number of parallel cores for {EpiNow2} --------------------------
withr::local_options(list(mc.cores = parallel::detectCores() - 1))


# Estimate transmission using EpiNow2::epinow() ---------------------------
# with EpiNow2::*_opts() functions for generation time, delays, and stan.
ebola_estimates <- EpiNow2::epinow(
  data = dat_ebola,
  generation_time = EpiNow2::generation_time_opts(ebola_generationtime),
  delays = EpiNow2::delay_opts(ebola_incubationtime_epinow + ebola_reportdelay),
  stan = EpiNow2::stan_opts(samples = 1000, chains = 3)
)


# Print plot and summary table outputs ------------------------------------
summary(ebola_estimates)
plot(ebola_estimates)
```

##### COVID (sample)

``` r
# Load packages -----------------------------------------------------------
library(epiparameter)
library(EpiNow2)
library(tidyverse)

# Read reported cases -----------------------------------------------------
dat_covid <- read_rds(
  "https://epiverse-trace.github.io/tutorials-middle/data/covid_30days.rds"
) %>%
  dplyr::select(date, confirm)

# Define a generation time from {epiparameter} to {EpiNow2} ---------------

# access a serial interval
covid_serialint <- epiparameter::epiparameter_db(
  disease = "covid",
  epi_name = "serial",
  single_epiparameter = TRUE
)

# extract parameters from {epiparameter} object
covid_serialint_params <- epiparameter::get_parameters(covid_serialint)

# adapt {epiparameter} to {EpiNow2} distribution inferfase
# preferred
covid_generationtime <- EpiNow2::LogNormal(
  meanlog = covid_serialint_params["meanlog"],
  sdlog = covid_serialint_params["sdlog"]
)
# or
covid_generationtime <- EpiNow2::LogNormal(
  mean = covid_serialint$summary_stats$mean,
  sd = covid_serialint$summary_stats$sd
)


# Define the delays from infection to case report for {EpiNow2} -----------

# define delay from symptom onset to case report
# or reporting delay
covid_reportdelay <- EpiNow2::Gamma(
  mean = EpiNow2::Normal(mean = 2, sd = 0.5),
  sd = EpiNow2::Normal(mean = 1, sd = 0.5),
  max = 5
)

# define a delay from infection to symptom onset
# or incubation period
covid_incubationtime <- epiparameter::epiparameter_db(
  disease = "covid",
  epi_name = "incubation",
  single_epiparameter = TRUE
)

# incubation period: extract distribution parameters
covid_incubationtime_params <- epiparameter::get_parameters(
  covid_incubationtime
)

# incubation period: discretize and extract maximum value (p = 99%)
# preferred
covid_incubationtime_max <- covid_incubationtime %>%
  epiparameter::discretise() %>%
  quantile(p = 0.99)
# or
ebola_incubationtime_max <- covid_incubationtime %>%
  quantile(p = 0.99) %>%
  base::round()

# incubation period: adapt to {EpiNow2} distribution interfase
covid_incubationtime_epinow <- EpiNow2::LogNormal(
  meanlog = covid_incubationtime_params["meanlog"],
  sdlog = covid_incubationtime_params["sdlog"],
  max = covid_incubationtime_max
)

# collect required input
covid_generationtime
covid_reportdelay
covid_incubationtime_epinow


# Set the number of parallel cores for {EpiNow2} --------------------------
withr::local_options(list(mc.cores = parallel::detectCores() - 1))


# Estimate transmission using EpiNow2::epinow() ---------------------------
# with EpiNow2::*_opts() functions for generation time, delays, and stan.
covid_estimates <- EpiNow2::epinow(
  data = dat_covid,
  generation_time = EpiNow2::generation_time_opts(covid_generationtime),
  delays = EpiNow2::delay_opts(covid_reportdelay + covid_incubationtime_epinow),
  stan = EpiNow2::stan_opts(samples = 1000, chains = 3)
)


# Print plot and summary table outputs ------------------------------------
summary(covid_estimates)
plot(covid_estimates)
```

#### Outputs

##### Group 1: COVID 30 days

With reporting delay plus Incubation time:
<img src="https://hackmd.io/_uploads/BJl8wYiDC.png" style="width:25.0%"
alt="image" />

With reporting delay plus Incubation time:

    > summary(covid30_epinow_delay)
                                measure               estimate
                                 <char>                 <char>
    1:           New infections per day  13193 (5129 -- 33668)
    2: Expected change in daily reports      Likely increasing
    3:       Effective reproduction no.      1.5 (0.92 -- 2.5)
    4:                   Rate of growth 0.099 (-0.049 -- 0.26)
    5:     Doubling/halving time (days)         7 (2.7 -- -14)

##### Group 2: Ebola 35 days

With reporting delay plus Incubation time:
<img src="https://hackmd.io/_uploads/H1ZrYYsvR.png" style="width:25.0%"
alt="image" />

With reporting delay plus Incubation time:

    > summary(ebola35_epinow_delays)
                                measure               estimate
                                 <char>                 <char>
    1:           New infections per day            5 (0 -- 26)
    2: Expected change in daily reports      Likely decreasing
    3:       Effective reproduction no.     0.66 (0.13 -- 2.2)
    4:                   Rate of growth -0.039 (-0.18 -- 0.12)
    5:     Doubling/halving time (days)      -18 (5.5 -- -3.9)

##### Group 3: Ebola 60 days

With reporting delay plus Incubation time:
<img src="https://hackmd.io/_uploads/Byu3FFoDR.png" style="width:25.0%"
alt="image" />

With reporting delay plus Incubation time:

    > summary(ebola60_epinow_delays)
                                measure                  estimate
                                 <char>                    <char>
    1:           New infections per day                0 (0 -- 0)
    2: Expected change in daily reports                Decreasing
    3:       Effective reproduction no.    0.038 (0.0013 -- 0.39)
    4:                   Rate of growth -0.16 (-0.32 -- -0.00055)
    5:     Doubling/halving time (days)      -4.4 (-1300 -- -2.2)

##### Group 4: COVID 60 days

With reporting delay plus Incubation time:
<img src="https://hackmd.io/_uploads/S1q6ItjvC.png" style="width:25.0%"
alt="image" />

With reporting delay plus Incubation time:

    > summary(covid60_epinow_delays)
                                measure               estimate
                                 <char>                 <char>
    1:           New infections per day     1987 (760 -- 4566)
    2: Expected change in daily reports      Likely decreasing
    3:       Effective reproduction no.     0.81 (0.43 -- 1.3)
    4:                   Rate of growth -0.047 (-0.2 -- 0.092)
    5:     Doubling/halving time (days)      -15 (7.5 -- -3.5)

#### Interpretation

Interpretation template:

- From the summary of our analysis we see that the expected change in
  reports is `Likely decreasing` with the estimated new infections, on
  average, of `1987` with 90% credible interval of `760` to `4566`.

- The effective reproduction number $R_t$ estimate (on the last date of
  the data), or the number of new infections caused by one infectious
  individual, on average, is `0.81`, with a 90% credible interval of
  `0.43` to `1.30`.

- The exponential growth rate of case reports is, on average `-0.047`,
  with a 90% credible interval of `-0.2` to `0.01`.

- The doubling time (the time taken for case reports to double) is, on
  average, `-15.0`, with a 90% credible interval of `7.5` to `-3.5`.

Interpretation Helpers:

- About the effective reproduction number:
  - An Rt greater than 1 implies an increase in cases or an epidemic.
  - An Rt less than 1 implies a decrease in cases or extinction.
- An analysis closest to extinction has a central estimate of:
  - Rt less than 1
  - growth rate is negative
  - doubling or halving time negative
- However, given the uncertainty in all of these estimates, there is no
  statistical evidence of extintion if the 90% credible intervals of:
  - Rt include the value 1,
  - growth rate include the value 0,
  - doubling or halving time include the value 0.
- From table:
  - The results in the tables correspond to the latest available date
    under analysis.
  - The `Expected change in reports` categories (e.g., `Stable` or
    `Likely decreasing`) describe the expected change in daily cases
    based on the posterior probability that Rt \< 1. Find the tutorial
    table at:
    <https://epiverse-trace.github.io/tutorials-middle/quantify-transmissibility.html#expected-change-in-reports>
- From figure:
  - The estimate of Reports fits the input incidence curve.
  - The forecast of New infections and Reports per day assumes no change
    in the reproduction number. For that reason, the forecast section of
    “Effective reproduction no.” is constant.
  - When we include at `delays` both the incubation and reporting delay,
    - In Reports, the forecast credible intervals increases.
    - New infections per day, uncertainty increases in an equivalent
      size to the delays
- From comparing COVID and Ebola outputs:
  - The finite maximum value of the generation time distribution defines
    de range of the “estimate based on parial data”.

## Activity 2: Severity

Estimate the *naive CFR (nCFR)* and *delay-adjusted CFR (aCFR)* using
the following inputs:

- reported cases (aggregate incidence by date of onset)
- onset to death delay

As a group, Write your answer to these questions:

- What phase of the epidemic are you observing? (Exponential growth
  phase, near peak, or decay end phase)
- How much difference there is between the aCFR estimate compares with
  the nCFR days later or before?
- Interpret: How would you communicate these results to a
  decision-maker?
- Compare: What differences you identify from other group outputs? (if
  available)

### Inputs

| Group | Incidence           | Link                                                                      |
|-------|---------------------|---------------------------------------------------------------------------|
| 1     | Ebola 20 days       | <https://epiverse-trace.github.io/tutorials-middle/data/ebola_20days.rds> |
| 2     | Ebola 35 days       | <https://epiverse-trace.github.io/tutorials-middle/data/ebola_35days.rds> |
| 3     | Ebola 60 days       | <https://epiverse-trace.github.io/tutorials-middle/data/ebola_60days.rds> |
| 4     | Diamond Princess XX | <paste link>                                                              |

### Solution

<!-- visible for instructors and learners after practical (solutions) -->

#### Code

##### Ebola (sample)

``` r
# Load packages -----------------------------------------------------------
library(cfr)
library(epiparameter)
library(tidyverse)


# Read reported cases -----------------------------------------------------
ebola_sev <- read_rds(
  "https://epiverse-trace.github.io/tutorials-middle/data/ebola_20days.rds"
)


# Access delay distribution -----------------------------------------------
ebola_delay <- epiparameter::epiparameter_db(
  disease = "ebola",
  epi_name = "onset-to-death",
  single_epiparameter = TRUE
)


# Estimate Static Naive CFR -----------------------------------------------
cfr::cfr_static(data = ebola_sev)

# Estimate Static Delay-Adjusted CFR --------------------------------------
cfr::cfr_static(
  data = ebola_sev,
  delay_density = function(x) density(ebola_delay, x)
)
```

#### Outputs

##### Ebola

| Analysis            | Outputs                                             |
|---------------------|-----------------------------------------------------|
| Incidence           | ![image](https://hackmd.io/_uploads/Hk2dcUiGyl.png) |
| CFR static: 20 days | ![image](https://hackmd.io/_uploads/SyK0YIofye.png) |
| CFR static: 35 days | ![image](https://hackmd.io/_uploads/BJQHhLjzkg.png) |
| CFR static: 60 days | ![image](https://hackmd.io/_uploads/BySI38oGyg.png) |
| CFR rolling         | ![image](https://hackmd.io/_uploads/BkyrKYiz1e.png) |

#### Interpretation

Interpretation template:

- As of `September 13`, the delay-adjusted case fatality risk is `73.4%`
  with a 95% confidence interval between `47.3%` and `91.4%`.

From figure and tables:

- Peak size in cases and deaths are similar. Peak location delayed ~7
  days.
- Ebola 20 days
  - For Ebola, at day 20, we estimate an aCFR of 67.9% with a 95%
    confidence interval from 42.6% to 87.5%.
  - The aCFR estimate is higher than the nCFR by ~+50%
- Ebola 35 days
  - The aCFR estimate is higher than the nCFR by ~+40%
  - The nCFR estimate at day 35 lies within the aCFR estimate at day 20.
  - The observed deaths are higher than the expected deaths, producing
    aCFR ~100%. Thus, a {cfr} output of missing values.
- Ebola 60 days
  - The aCFR estimate is close to the nCFR by ~+6%
  - The nCFR estimate at day 60 lies within the aCFR estimate at day 35.
  - The aCFR converge to true CFR at the end of the outbreak.
- Overall
  - In Ebola, the delay-adjusted CFR (aCFR) helps us get an earlier
    estimate of the true CFR, compared to the naive CFR (nCFR).

Complementary notes:

- `cfr::static()` assumption and limitations
  - One key assumption of `cfr::static()` is that reporting rate and
    fatality risk is consistent over the time window considered. (This
    does not hold for COVID)
  - Early data had limitations (limited testing, changing case
    definitions, often only most severe being tested -a.k.a.,
    preferential assessertainment-). So neither method (aCFR nor nCFR)
    gives the ‘true’ % of fatal symptomatic cases (which is closer to
    around 2% based on better datasets).
  - `cfr::static()` it’s therefore most useful over much longer
    timeseries for COVID for context.
  - Alternativelly, `{cfr}` can also estimate the proportion of cases
    that are ascertained during an outbreak using
    `cfr::estimate_ascertainment()`.

# Continue your learning path

<!-- Suggest learners to Epiverse-TRACE documentation or external resources --->

{EpiNow2} Case studies and use in the literature

- <https://epiforecasts.io/EpiNow2/articles/case-studies.html>

{cfr} Estimating the proportion of cases that are ascertained during an
outbreak

- <https://epiverse-trace.github.io/cfr/articles/estimate_ascertainment.html>

# Paste your !Error messages here






# end
