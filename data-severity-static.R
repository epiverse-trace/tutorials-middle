#' aim:
#' formative assessment in severity episode

library(cfr)
library(epiparameter)
library(incidence2)
library(outbreaks)
library(tidyverse)

sarscov2_incidence <- sarscov2_who_2019 %>%
  incidence2::incidence(
    date_index = "date",
    counts = c(
      "cases_jpn",
      "deaths_jpn"
    ),
    complete_dates = TRUE
  )

sarscov2_incidence

plot(sarscov2_incidence)

sarscov2_incidence %>%
  cfr::prepare_data(
    cases_variable = "cases_jpn",
    deaths_variable = "deaths_jpn"
  ) %>%
  dplyr::rename(
    cases_jpn = cases,
    deaths_jpn = deaths
  ) %>%
  dplyr::as_tibble() %>%
  readr::write_csv(file.path("episodes", "data", "sarscov2_cases_deaths.csv"))

sarscov2_input <- readr::read_csv(file.path(
  "episodes",
  "data",
  "sarscov2_cases_deaths.csv"
))

