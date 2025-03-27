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

# adapt {epiparameter} to {EpiNow2} distribution inferfase
ebola_serialint_params <- epiparameter::get_parameters(ebola_serialint)

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
  mean = EpiNow2::Normal(mean = 4, sd = 0.5),
  sd = EpiNow2::Normal(mean = 1, sd = 0.5),
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
dat_epinow <- EpiNow2::epinow(
  data = dat,
  generation_time = EpiNow2::generation_time_opts(ebola_generationtime),
  delays = EpiNow2::delay_opts(ebola_incubationtime_epinow + ebola_reportdelay),
  stan = EpiNow2::stan_opts(samples = 1000, chains = 3)
)


# Print plot and summary table outputs ------------------------------------
plot(dat_epinow)
summary(dat_epinow)
```

Interpretation:

## Severity

# Solutions

<!-- visible for instructors and learners after practical (solutions) -->

solutions

# end
