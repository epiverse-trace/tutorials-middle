# Week 3: Estimate superspreading and simulate transmission chains

<!-- visible for instructors only -->
<!-- practical-week.md is generated from practical-week.qmd. Please edit that file -->
<!-- commit .md and .qmd files together -->

These practical is based in the following tutorial episodes:

- <https://epiverse-trace.github.io/tutorials-middle/superspreading-estimate.html>
- <https://epiverse-trace.github.io/tutorials-middle/superspreading-simulate.html>

During the practical, instead of copy-paste, encourage learners to
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
- Group 5: …, …
- Group 6: …, …

# Practical

<!-- visible for learners and instructors at practical -->

This practical has two activities.

Before your start, as a group:

- Create one copy of the Posit Cloud project `<paste link>`.
- Solve each challenge using the `Code chunk` as a guide.
- Paste your figure and table outputs.
- Write your answer to the questions.
- Choose one person from your group to share your results with everyone.

## Activity 1: Account for superspreading

Estimate extent of individual-level variation (i.e. the dispersion
parameter) of the offspring distribution and the proportion of
transmission that is linked to ‘superspreading events’ using the
following available inputs:

- Line list of cases
- Contact tracing data

As a group, Write your answer to these questions:

- What set has more infections related to fewer clusters in the contact
  network?
- What set has the most skewed histogram of secondary cases?
- Does the estimated dispersion parameter correlate with the contact
  network and histogram of secondary cases?
- What is the proportion of new cases originating from a cluster of at
  least 10 cases?
- Would you recommend a backward tracing strategy?
- Interpret: How would you communicate these results to a
  decision-maker?
- Compare: What differences you identify from other group outputs? (if
  available)

### Inputs

| Group | Data                                                                                                                                                       |
|-------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1     | <https://epiverse-trace.github.io/tutorials-middle/data/set-01-contacts.rds>, <https://epiverse-trace.github.io/tutorials-middle/data/set-01-linelist.rds> |
| 2     | <https://epiverse-trace.github.io/tutorials-middle/data/set-02-contacts.rds>, <https://epiverse-trace.github.io/tutorials-middle/data/set-02-linelist.rds> |
| 3     | <https://epiverse-trace.github.io/tutorials-middle/data/set-03-contacts.rds>, <https://epiverse-trace.github.io/tutorials-middle/data/set-03-linelist.rds> |
| 4     | <https://epiverse-trace.github.io/tutorials-middle/data/set-04-contacts.rds>, <https://epiverse-trace.github.io/tutorials-middle/data/set-04-linelist.rds> |
| 5     | <https://epiverse-trace.github.io/tutorials-middle/data/set-05-contacts.rds>, <https://epiverse-trace.github.io/tutorials-middle/data/set-05-linelist.rds> |
| 6     | <https://epiverse-trace.github.io/tutorials-middle/data/set-06-contacts.rds>, <https://epiverse-trace.github.io/tutorials-middle/data/set-06-linelist.rds> |

### Solution

<!-- visible for instructors and learners after practical (solutions) -->

#### Code

##### Set 1 (sample)

``` r
# Load packages -----------------------------------------------------------
library(epicontacts)
library(fitdistrplus)
library(tidyverse)


# Read linelist and contacts ----------------------------------------------
dat_contacts <- readr::read_rds(
  "https://epiverse-trace.github.io/tutorials-middle/data/set-01-contacts.rds"
)

dat_linelist <- readr::read_rds(
  "https://epiverse-trace.github.io/tutorials-middle/data/set-01-linelist.rds"
)


# Create an epicontacts object -------------------------------------------
epi_contacts <-
  epicontacts::make_epicontacts(
    linelist = dat_linelist,
    contacts = dat_contacts,
    directed = TRUE
  )

epi_contacts

# visualize the contact network
contact_network <- epicontacts::vis_epicontacts(epi_contacts)

contact_network


# Count secondary cases per subject in contacts and linelist --------
secondary_cases <- epicontacts::get_degree(
  x = epi_contacts,
  type = "out",
  only_linelist = TRUE
)

# plot the histogram of secondary cases
individual_reproduction_num <- secondary_cases %>%
  enframe() %>%
  ggplot(aes(value)) +
  geom_histogram(binwidth = 1) +
  labs(
    x = "Number of secondary cases",
    y = "Frequency"
  )

individual_reproduction_num


# Fit a negative binomial distribution -----------------------------------
offspring_fit <- secondary_cases %>%
  fitdistrplus::fitdist(distr = "nbinom")

offspring_fit


# Estimate proportion of new cases from a cluster of secondary cases -----

# Set seed for random number generator
set.seed(33)

# Estimate the proportion of new cases originating from 
# a transmission cluster of at least 5, 10, or 25 cases
proportion_cases_by_cluster_size <-
  superspreading::proportion_cluster_size(
    R = offspring_fit$estimate["mu"],
    k = offspring_fit$estimate["size"],
    cluster_size = c(5, 10, 25)
  )

proportion_cases_by_cluster_size
```

#### Outputs

Group 1

<img src="https://hackmd.io/_uploads/H1DVLbsTyx.png" style="width:25.0%"
alt="Untitled-1" />
<img src="https://hackmd.io/_uploads/BkW48Wo6yg.png" style="width:25.0%"
alt="Untitled" />

Group 2

<img src="https://hackmd.io/_uploads/Hkhg8WspJg.png" style="width:25.0%"
alt="Untitled" />
<img src="https://hackmd.io/_uploads/HyIlUWopJx.png" style="width:25.0%"
alt="Untitled-1" />

Group 3

<img src="https://hackmd.io/_uploads/HkzkUZjpyx.png" style="width:25.0%"
alt="Untitled" />
<img src="https://hackmd.io/_uploads/SkjCBZjpJe.png" style="width:25.0%"
alt="Untitled-1" />

Group 1/2/3

``` r
#>     R    k prop_5 prop_10 prop_25
#> 1 0.8 0.01  95.1%   89.8%   75.1%
#> 2 0.8 0.10  66.7%   38.7%    7.6%
#> 3 0.8 0.50  25.1%    2.8%      0%
```

#### Interpretation

Interpretation template:

- For R = 0.8 and k = 0.01:
  - The proportion of new cases originating from a cluster of at least 5
    secondary cases from a primary case is 95%
  - The proportion of all transmission event that were part of secondary
    case clusters (i.e., from the same primary case) of at least 5 cases
    is 95%

Interpretation Helpers:

- From the contact network, set 1 has the highest frequency of
  infections related with a small proportion of clusters.
- From the histogram of secondary cases, skewness in set 1 is higher
  than set 2 and set 3.
- Set 1 has cases with the highest number of secondary cases (n = 50),
  compared with set 2 (n = ~25) and set 3 (n = 11).
- The contact networks and histograms of secondary cases correlate with
  the estimated dispersion parameters: A small proportion of clusters
  generating most of new cases produces a more skewed histogram, and a
  lowest estimate of dispersion parameter.
- About probabilty of new cases from transmission cluster of size at
  least 10 cases, and the recommending backward tracing strategy:
  - set 1: 89%, yes.
  - set 2: 38%, probably no?
  - set 3: 3%, no.

## Activity 2: Simulate transmission chains

Estimate the potential for large outbreaks using the following available
inputs:

- Basic reproduction number
- Dispersion parameter

As a group, Write your answer to these questions:

- Explore the data frame output of the `Simulation ID`: What is the
  relationship between the following columns `chain`, `infector`,
  `infectee`, `generation`, `time`, `simulation_id`?
- Among simulated outbreaks:
  - How many chains reached a 100 case threshold?
  - What is the maximum size of chain?
  - What is the maximum length of chain?
- Interpret: How would you communicate these results to a
  decision-maker?
- Compare: What differences you identify from other group outputs? (if
  available)

### Inputs

| Group | Parameters        | Simulation ID |
|-------|-------------------|---------------|
| 1     | R = 0.8, k = 0.01 | 683           |
| 2     | R = 0.8, k = 0.1  | 664           |
| 3     | R = 0.8, k = 0.5  | 256           |
| 4     | R = 1.5, k = 0.01 | 129           |
| 5     | R = 1.5, k = 0.1  | 301           |
| 6     | R = 1.5, k = 0.5  | 227           |

### Solution

<!-- visible for instructors and learners after practical (solutions) -->

#### Code

##### Set 1 (sample)

``` r
# Load packages -----------------------------------------------------------
library(epiparameter)
library(epichains)
library(tidyverse)


# Set input parameters ---------------------------------------------------
known_basic_reproduction_number <- 0.8
known_dispersion <- 0.01
simulation_to_explore <- 683


# Set iteration parameters -----------------------------------------------

# Number of simulation runs
number_chains <- 1000

# Number of initial cases
initial_cases <- 1

# Create generation time as <epiparameter> object
generation_time <- epiparameter::epiparameter(
  disease = "disease x",
  epi_name = "generation time",
  prob_distribution = "gamma",
  summary_stats = list(mean = 3, sd = 1)
)


# Simulate multiple chains -----------------------------------------------
# run all this section together

# Set seed for random number generator
set.seed(33)

simulated_chains_map <-
  # iterate one function across multiple numbers (simulation IDs)
  map(
    # vector of numbers (simulation IDs)
    .x = seq_len(number_chains),
    # function to iterate to each simulation ID number
    .f = function(sim) {
      simulate_chains(
        # simulation controls
        n_chains = initial_cases,
        statistic = "size",
        stat_threshold = 500,
        # offspring
        offspring_dist = rnbinom,
        mu = known_basic_reproduction_number,
        size = known_dispersion,
        # generation
        generation_time = function(x) generate(x = generation_time, times = x)
      ) %>%
        # creates a column with the simulation ID number
        mutate(simulation_id = sim)
    }
  ) %>%
  # combine list outputs (for each simulation ID) into a single data frame
  list_rbind()

simulated_chains_map


# Explore suggested chain ------------------------------------------------
simulated_chains_map %>%
  # use data.frame output from <epichains> object
  as_tibble() %>% 
  filter(simulation_id == simulation_to_explore) %>% 
  print(n=Inf)


# visualize ---------------------------------------------------------------

# daily aggregate of cases
simulated_chains_day <- simulated_chains_map %>%
  # use data.frame output from <epichains> object
  as_tibble() %>%
  # transform simulation ID column to factor (categorical variable)
  mutate(simulation_id = as_factor(simulation_id)) %>%
  # get the round number (day) of infection times
  mutate(day = ceiling(time)) %>%
  # count the daily number of cases in each simulation (simulation ID)
  count(simulation_id, day, name = "cases") %>%
  # calculate the cumulative number of cases for each simulation (simulation ID)
  group_by(simulation_id) %>%
  mutate(cases_cumsum = cumsum(cases)) %>%
  ungroup()

# Visualize transmission chains by cumulative cases
ggplot() +
  # create grouped chain trajectories
  geom_line(
    data = simulated_chains_day,
    mapping = aes(
      x = day,
      y = cases_cumsum,
      group = simulation_id
    ),
    color = "black",
    alpha = 0.25,
    show.legend = FALSE
  ) +
  # define a 100-case threshold
  geom_hline(aes(yintercept = 100), lty = 2) +
  labs(
    x = "Day",
    y = "Cumulative cases"
  )
```

#### Outputs

Group 1

<img src="https://hackmd.io/_uploads/H1DVLbsTyx.png" style="width:25.0%"
alt="Untitled-1" />
<img src="https://hackmd.io/_uploads/BkW48Wo6yg.png" style="width:25.0%"
alt="Untitled" />
<img src="https://hackmd.io/_uploads/Sy2QUZiTJl.png" style="width:25.0%"
alt="Untitled-1" />

Group 2

<img src="https://hackmd.io/_uploads/Hkhg8WspJg.png" style="width:25.0%"
alt="Untitled" />
<img src="https://hackmd.io/_uploads/HyIlUWopJx.png" style="width:25.0%"
alt="Untitled-1" />
<img src="https://hackmd.io/_uploads/SkRyUWjp1x.png" style="width:25.0%"
alt="Untitled" />

Group 3

<img src="https://hackmd.io/_uploads/HkzkUZjpyx.png" style="width:25.0%"
alt="Untitled" />
<img src="https://hackmd.io/_uploads/SkjCBZjpJe.png" style="width:25.0%"
alt="Untitled-1" />
<img src="https://hackmd.io/_uploads/BkfABZopye.png" style="width:25.0%"
alt="Untitled" />

Sample

``` r
# infector-infectee data frame 
simulated_chains_map %>%
  dplyr::filter(simulation_id == 806) %>%
  dplyr::as_tibble()
```

    # A tibble: 9 × 6
      chain infector infectee generation  time simulation_id
      <int>    <dbl>    <dbl>      <int> <dbl>         <int>
    1     1       NA        1          1   0             806
    2     1        1        2          2  16.4           806
    3     1        1        3          2  11.8           806
    4     1        1        4          2  10.8           806
    5     1        1        5          2  11.4           806
    6     1        1        6          2  10.2           806
    7     1        2        7          3  26.0           806
    8     1        2        8          3  29.8           806
    9     1        2        9          3  26.6           806

#### Interpretation

Interpretation template:

- Simulation `806` have `1` chain with `3` known infectors (`NA`, 1, 2),
  and `3` generations.
- In the generation 0, subject `NA` infected subject 1.
- In the generation 1, subject 1 infected subjects 2, 3, 4, 5, 6. These
  infections occurred between day 10 and 16 after the “case zero”.
- In the generation 2, subject 2 infected subjects 7, 8, 9. These
  infections occurred between day 26 and 29 after the “case zero”.

Interpretation Helpers:

- Group 1:
  - 1 chain above 100
  - size of chain ~130
  - length of chain ~20 days
- Group 2:
  - 6 chains above 100
  - size of chain of 500
  - length of chain ~50 days
- Group 3:
  - 2 chains above 100
  - size of chain of 150
  - length of chain ~60 days

# Continue your learning path

<!-- Suggest learners to Epiverse-TRACE documentation or external resources --->

{superspreading} vignette on epidemic risk

- <https://epiverse-trace.github.io/superspreading/articles/epidemic_risk.html>

{epichains} vignette on projecting infectious disease incidence

- <https://epiverse-trace.github.io/epichains/articles/projecting_incidence.html>

Epi R handbook episode on {epicontacts} to visualise transmission chains
in time

- <https://www.epirhandbook.com/en/transmission-chains.html>

# Paste your !Error messages here






# end
