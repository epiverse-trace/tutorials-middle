
#' COMPLETE
#' - access one epidemiological delay for covid
#' - estimate naive CFR
#' - estimate delay-adjusted CFR

# package ----------------------------------------------------------------

library(cfr)
library(incidence2)
library(tidyverse)

# data -------------------------------------------------------------------

covid_all <- incidence2::covidregionaldataUK %>% 
  as_tibble() %>% 
  filter(region == "North East") %>% 
  incidence2::incidence(
    date_index = "date",
    counts = c("cases_new","deaths_new"),
    complete_dates = TRUE) %>% 
  cfr::prepare_data(cases_variable = "cases_new",
                    deaths_variable = "deaths_new") 

covid_section <- covid_all %>% 
  dplyr::filter(date > ymd(20200305) & date < ymd(20200505))


# COMPLETE ---------------------------------------------------------------

# access one epidemiological delay -----------------------------------------

covid_delay <- epiparameter::epidist_db(
  disease = "covid",
  epi_dist = "onset-to-death",
  single_epidist = TRUE
)

# naive severity ---------------------------------------------------------

covid_all %>% 
  cfr::cfr_static()

# delay adjusted severity -----------------------------------------

covid_section %>% 
  cfr::cfr_static(delay_density = function(x) density(covid_delay,x))
