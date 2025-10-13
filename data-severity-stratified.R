# mers
# stratified by groups

# Load packages -----------------------------------------------------------
library(cfr)
library(epiparameter)
library(tidyverse)


# Read reported cases -----------------------------------------------------
mers_linelist <- outbreaks::mers_korea_2015$linelist %>%
  tibble::as_tibble() %>%
  dplyr::mutate(
    age_category = base::cut(
      x = age,
      breaks = c(10, 30, 50, 70, 90), # replace with max value if known
      include.lowest = TRUE,
      right = FALSE
    )
  ) %>%
  dplyr::select(id, age_category, dt_onset, dt_death)

mers_sev <- mers_linelist %>%
  # skimr::skim(age)
  # dplyr::count(age_class, age_category)
  # converto to incidence2 object
  incidence2::incidence(
    date_index = c("dt_onset", "dt_death"),
    groups = "age_category",
    complete_dates = TRUE
  ) %>%
  # plot()
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


# alternative ------------------------------------------------------------

mers_linelist %>% 
  # converto to incidence2 object
  incidence2::incidence(
    date_index = c("dt_onset", "dt_death"),
    # groups = "age_category",
    complete_dates = TRUE
  ) %>%
  # plot()
  # convert to cfr format
  cfr::prepare_data(
    cases_variable = "dt_onset",
    deaths_variable = "dt_death"
  )

# save data
mers_linelist %>%
  readr::write_rds(file.path("episodes", "data", "mers_linelist.rds"))

readr::read_rds(file.path(
  "episodes",
  "data",
  "mers_linelist.rds"
))
