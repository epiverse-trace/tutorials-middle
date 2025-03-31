# Week 3: Estimate superspreading and simulate transmission chains

<!-- visible for instructors only -->
<!-- practical-week.md is generated from practical-week.qmd. Please edit that file -->
<!-- commit .md and .qmd files together -->

Welcome!

A reminder of our Code of Conduct:
<https://github.com/epiverse-trace/.github/blob/main/CODE_OF_CONDUCT.md>

# Practical

<!-- visible for learners and instructors at practical -->

Before your start, as a group: - Create one copy of the Posit Cloud
project `<paste link>`. - Solve each challenge using the `Code chunk` as
a guide. - Paste your figure and table outputs. - Write your answer to
the questions. - Choose one person from your group to share your results
with everyone.

## Theme

Estimate … using the following available inputs:

- input 1
- input 2

As a group, Write your answer to these questions:

- … phase?
- … results expected?
- Interpret: How would you communicate these results to a
  decision-maker?
- Compare: What differences you identify from other group outputs? (if
  available)

### Inputs

| Group | Incidence     | Link                                                                      |
|-------|---------------|---------------------------------------------------------------------------|
| 1     | COVID 30 days | <https://epiverse-trace.github.io/tutorials-middle/data/covid_30days.rds> |
| 2     | Ebola 35 days |                                                                           |
| 3     | Ebola 60 days |                                                                           |
| 4     | COVID 60 days |                                                                           |

| Disease | params |
|---------|--------|
| Ebola   | …      |
| COVID   | …      |

### Solution

<!-- visible for instructors and learners after practical (solutions) -->

#### Code

``` r
# Load packages -----------------------------------------------------------
library(epiparameter)
library(EpiNow2)
library(tidyverse)

# Read reported cases -----------------------------------------------------

# runnable howto-like
```

#### Outputs

##### Group 4: COVID 60 days

With reporting delay plus Incubation time:
<img src="https://hackmd.io/_uploads/S1q6ItjvC.png" style="width:50.0%"
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

- …

Interpretation Helpers:

- About the effective reproduction number:
  - An Rt greater than 1 implies an increase in cases or an epidemic.
  - An Rt less than 1 implies a decrease in cases or extinction.
- …

# end
