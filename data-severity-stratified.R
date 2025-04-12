# mers
# stratified by groups

# Load packages -----------------------------------------------------------
library(cfr)
library(epiparameter)
library(tidyverse)


# Read reported cases -----------------------------------------------------
mers_sev <- outbreaks::mers_korea_2015$linelist %>%
  as_tibble() %>%
  dplyr::mutate(
    age_category = base::cut(
      x = age,
      breaks = c(0, 70, 90), # replace with max value if known
      include.lowest = TRUE,
      right = FALSE
    )
  ) %>%
  # skimr::skim(age)
  # dplyr::count(age_class, age_category)
  # converto to incidence2 object
  incidence2::incidence(
    date_index = c("dt_onset", "dt_death"),
    groups = "age_category",
    complete_dates = TRUE
  ) %>%
  # convert to cfr format
  cfr::prepare_data(
    cases_variable = "dt_onset",
    deaths_variable = "dt_death"
  )

# save data
mers_sev %>%
  readr::write_rds(file.path("episodes", "data", "mers_byage.rds"))

readr::read_rds(file.path(
  "episodes",
  "data",
  "mers_byage.rds"
))
