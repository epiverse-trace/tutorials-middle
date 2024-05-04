library(cfr)
library(epiparameter)
library(incidence2)
library(outbreaks)
library(tidyverse)

sarscov2_incidence <- sarscov2_who_2019 %>%
  incidence(
    date_index = "date",
    counts = c(
      "cases_jpn",
      "deaths_jpn"
    )
  ) %>%
  complete_dates()

sarscov2_incidence

sarscov2_incidence %>%
  prepare_data(
    cases_variable = "cases_jpn",
    deaths_variable = "deaths_jpn"
  ) %>%
  rename(
    cases_jpn = cases,
    deaths_jpn = deaths
  ) %>%
  as_tibble() %>%
  write_csv(file.path("episodes", "data", "sarscov2_cases_deaths.csv"))

sarscov2_input <- read_csv(file.path("episodes",
                                     "data", "sarscov2_cases_deaths.csv"))

sarscov2_input

sarscov2_delay <-
  epidist_db(
    disease = "covid",
    epi_dist = "onset to death",
    single_epidist = TRUE
  )

sarscov2_input %>%
  dplyr::rename(
    cases = cases_jpn,
    deaths = deaths_jpn
  ) %>%
  cfr_static()

sarscov2_input %>%
  dplyr::rename(
    cases = cases_jpn,
    deaths = deaths_jpn
  ) %>%
  cfr_static(delay_density = function(x) density(sarscov2_delay, x))
