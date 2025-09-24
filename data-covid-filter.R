#' aim
#' summative assessments for group challenges

library(tidyverse)
library(incidence2)

# read data ---------------------------------------------------------------

incidence_class <- incidence2::covidregionaldataUK %>%
  as_tibble() %>%
  filter(region == "London") %>%
  # preprocess missing values
  tidyr::replace_na(
    list(
      deaths_new = 0,
      cases_new = 0
    )
  ) %>%
  # compute the daily incidence
  incidence2::incidence(
    date_index = "date",
    counts = c("cases_new","deaths_new"),
    date_names_to = "date",
    complete_dates = TRUE
  ) %>%
  identity()

# number of dates ---------------------------------------------------------

incidence_class %>%
  count(date) %>%
  nrow()

incidence_class %>%
  filter(date < ymd(20200415)) %>%
  count(date) %>%
  nrow()

incidence_class %>%
  filter(date < ymd(20200701)) %>%
  count(date) %>%
  nrow()

# plot incidence ----------------------------------------------------------

incidence_class %>%
  plot()

incidence_class %>%
  filter(date < ymd(20200415)) %>%
  plot()

incidence_class %>%
  filter(date < ymd(20200701)) %>%
  plot()

# adapt for cfr -----------------------------------------------------------

covid_incidence2 <- incidence_class %>%
  cfr::prepare_data(
    cases_variable = "cases_new",
    deaths_variable = "deaths_new") %>%
  as_tibble()

covid_incidence2


# write data --------------------------------------------------------------

covid_incidence2 %>%
  filter(date < ymd(20200415)) %>%
  write_rds(file.path("episodes", "data", "covid_70days.rds"))

covid_incidence2 %>%
  filter(date < ymd(20200701)) %>%
  write_rds(file.path("episodes", "data", "covid_150days.rds"))

covid_incidence2 %>%
  write_rds(file.path("episodes", "data", "covid_490days.rds"))
