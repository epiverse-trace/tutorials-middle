# Week 2: Access delays to estimate transmission and severity

<!-- visible for instructors only -->
<!-- practical-week.md is generated from practical-week.qmd. Please edit that file -->
<!-- commit .md and .qmd files together -->

Welcome!

A reminder of our Code of Conduct:
<https://github.com/epiverse-trace/.github/blob/main/CODE_OF_CONDUCT.md>

# Practical

<!-- visible for learners and instructors at practical -->

## Transmission

Estimate $R_{t}$, *new infections*, *new reports*, *growth rate*, and
*doubling/halving time* using the following available inputs:

- Incidence of reported cases per day
- Reporting delay

Instructions, as a group:

- Create one copy of the Posit Cloud project `<paste link>`.
- Solve the challenge using the `Code chunk` as a guide.
- Paste your figure and table outputs.
- Write your answer to these questions:
  - What phase of the epidemic are you observing? (Exponential growth
    phase, near peak, or decay end phase)
  - Is the expected change in daily reports consistent with the
    estimated effective reproductive number, growth rate, and doubling
    time?
  - Interpret: How would you communicate these results to a
    decision-maker?
  - Compare: What differences you identify from other group outputs? (if
    available)
- Choose one person from your group to share your results with everyone.

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

``` r
# Load packages -----------------------------------------------------------
library(epiparameter)
library(EpiNow2)
library(tidyverse)

# Read reported cases -----------------------------------------------------
dat <- readr::read_rds(
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
#> - gamma distribution:
#>   shape:
#>     2.2
#>   rate:
#>     0.15
ebola_reportdelay
#> - lognormal distribution (max: 5):
#>   meanlog:
#>     - normal distribution:
#>       mean:
#>         1.4
#>       sd:
#>         0.5
#>   sdlog:
#>     - normal distribution:
#>       mean:
#>         0.25
#>       sd:
#>         0.2
ebola_incubationtime_epinow
#> - gamma distribution (max: 38):
#>   shape:
#>     1.6
#>   rate:
#>     0.15


# Set the number of parallel cores for {EpiNow2} --------------------------
withr::local_options(list(mc.cores = parallel::detectCores() - 1))


# Estimate transmission using EpiNow2::epinow() ---------------------------
# with EpiNow2::*_opts() functions for generation time, delays, and stan.
estimates <- EpiNow2::epinow(
  data = dat,
  generation_time = EpiNow2::generation_time_opts(ebola_generationtime),
  delays = EpiNow2::delay_opts(ebola_incubationtime_epinow + ebola_reportdelay),
  stan = EpiNow2::stan_opts(samples = 1000, chains = 3)
)
#> WARN [2025-03-28 12:25:53] epinow: There were 89 divergent transitions after warmup. See
#> https://mc-stan.org/misc/warnings.html#divergent-transitions-after-warmup
#> to find out why this is a problem and how to eliminate them. - 
#> WARN [2025-03-28 12:25:53] epinow: Examine the pairs() plot to diagnose sampling problems
#>  - 
#> WARN [2025-03-28 12:25:54] epinow: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess - 
#> WARN [2025-03-28 12:25:54] epinow: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess -


# Print plot and summary table outputs ------------------------------------
plot(estimates)
```

![](practical-delays_files/figure-commonmark/unnamed-chunk-2-1.png)

``` r
summary(estimates)
#>                         measure               estimate
#>                          <char>                 <char>
#> 1:       New infections per day          29 (11 -- 62)
#> 2:   Expected change in reports             Increasing
#> 3:   Effective reproduction no.         2.1 (1.1 -- 3)
#> 4:               Rate of growth 0.059 (-0.0099 -- 0.1)
#> 5: Doubling/halving time (days)        12 (6.9 -- -70)
```

Interpretation:

- From the summary of our analysis we see that the expected change in
  reports is Increasing with the estimated new infections of 29 with 90%
  credible interval of 11 to 62.

- The effective reproduction number $R_t$ estimate (on the last date of
  the data), or the number of new infections caused by one infectious
  individual, on average, is 2.1, with a 90% credible interval of 1.1 to
  3.

- The exponential growth rate of case reports is 0.059 (-0.0099 – 0.1).

- The doubling time (the time taken for case reports to double) is 12
  (6.9 – -70).

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
    `likely decreasing`) describe the expected change in daily cases
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

## Severity

### Solution

<!-- visible for instructors and learners after practical (solutions) -->

solutions

Interpretation:

As of September 13, the time lag-adjusted risk of case death is 73.4%
with a 95% confidence interval between 47.3 and 91.4%.

# end
