
#' COMPLETE
#' - add option to run parallel with 4 cores
#' - complete epinow() function with data, generational time and delay
#' - add STAN options to epinow() function for 1000 samples and 3 strings

# packages ----------------------------------------------------------------

library(tidyverse)
library(EpiNow2)

# data -------------------------------------------------------------------

ebola_confirmed <- read_csv("https://epiverse-trace.github.io/tutorials-middle/data/ebola_cases.csv")

serial_interval_ebola <-
  EpiNow2::Gamma(
    shape = 2.19,
    scale = 6.49,
    max = 45
  )

incubation_period_ebola <-
  EpiNow2::Gamma(
    shape = 1.58,
    scale = 6.53,
    max = 45
  )

# epinow ------------------------------------------------------------------


# complete cores ---------------------------------------------------------

withr::local_options(list(mc.cores = 4))

# complete epinow() ------------------------------------------------------

epinow_estimates <- EpiNow2::epinow(
  # cases
  data = ebola_confirmed,
  generation_time = EpiNow2::generation_time_opts(serial_interval_ebola),
  delays = EpiNow2::delay_opts(incubation_period_ebola),
  stan = EpiNow2::stan_opts(samples = 1000,chains = 3)
)

plot(epinow_estimates)