# Group Challenge Week 2: Access delays to estimate transmission and
severity

<!-- visible for instructors only -->
<!-- practical-week.md is generated from practical-week.qmd. Please edit that file -->
<!-- commit .md and .qmd files together -->

Welcome!

A reminder of our Code of Conduct:
<https://github.com/epiverse-trace/.github/blob/main/CODE_OF_CONDUCT.md>

# Practical

<!-- visible for learners and instructors at practical -->

## Transmission

Instructions, as a group:

- Create a copy of the Posit Cloud project `<paste link>` (one per
  group)
- Access the required Input Parameters
- Add the required delays for an appropriate estimate of the effective
  reproduction number
- **REPORT:** Reply pasting the code ready to run as a comment.

### Input Data

Based on you group number, choose your data set to work:

1.  COVID 30 dias:
    <https://epiverse-trace.github.io/tutorials-middle/data/covid_30days.rds>
2.  Ebola 35 dias:
    <https://epiverse-trace.github.io/tutorials-middle/data/ebola_35days.rds>
3.  Ebola 60 dias:
    <https://epiverse-trace.github.io/tutorials-middle/data/ebola_60days.rds>
4.  COVID 60 dias:
    <https://epiverse-trace.github.io/tutorials-middle/data/covid_60days.rds>

### Input Parameters

- Non-explicit input parameters could be accessed from historical
  outbreaks.
- Ebola:
  - The time difference between symptom onset and case report follows a
    Lognormal distribution with uncertainty. The **mean** follows a
    Normal distribution with mean = 4 and sd = 0.5. The **standard
    deviation** follows a Normal distribution with mean = 1 and sd =
    0.5. Bound the distribution with max = 5.
- COVID
  - The time difference between symptom onset and case report follows a
    Gamma distribution with uncertainty. The **mean** follows a Normal
    distribution with mean = 2 and sd = 0.5. The **standard deviation**
    follows a Normal distribution with mean = 1 and sd = 0.5. Bound the
    distribution with a max = 5.

### Write your solution

``` r
# Load packages
library(epiparameter)
library(EpiNow2)
library(tidyverse)

# Read data frame
covid30 <- read_rds("paste/url/here") %>%
  dplyr::select(date, confirm)

# Access parameters


# Get maximum value for the distribution


# Adapt {epiparameter} to {EpiNow2} distribution interfase


# Run EpiNow2::epinow() using EpiNow2::*_opts() functions


# Plot {EpiNow2} output
```

## Severity

# Solutions

<!-- visible for instructors and learners after practical (solutions) -->

solutions

# end
