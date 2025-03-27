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
  - Does the expected change in daily reports consistent with the
    estimated effective reproductive number, growth rate, and doubling
    time?
  - Interpret: How would you communicate these results to a
    decision-maker?
- **Report** to all the group at the end of the session.

### Inputs

| Group | Incidence     | Link                                                                      |
|-------|---------------|---------------------------------------------------------------------------|
| 1     | COVID 30 days | <https://epiverse-trace.github.io/tutorials-middle/data/covid_30days.rds> |
| 2     | Ebola 35 days | <https://epiverse-trace.github.io/tutorials-middle/data/ebola_35days.rds> |
| 3     | Ebola 60 days | <https://epiverse-trace.github.io/tutorials-middle/data/ebola_60days.rds> |
| 4     | COVID 60 days | <https://epiverse-trace.github.io/tutorials-middle/data/covid_60days.rds> |

| Disease | Reporting delays                                                                                                                                                                                                                                                                                              |
|---------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Ebola   | The time difference between symptom onset and case report follows a Lognormal distribution with uncertainty. The **mean** follows a Normal distribution with mean = 4 and sd = 0.5. The **standard deviation** follows a Normal distribution with mean = 1 and sd = 0.5. Bound the distribution with max = 5. |
| COVID   | The time difference between symptom onset and case report follows a Gamma distribution with uncertainty. The **mean** follows a Normal distribution with mean = 2 and sd = 0.5. The **standard deviation** follows a Normal distribution with mean = 1 and sd = 0.5. Bound the distribution with a max = 5.   |

### Solutions

<!-- visible for instructors and learners after practical (solutions) -->

solutions

## Severity

# Solutions

<!-- visible for instructors and learners after practical (solutions) -->

solutions

# end
