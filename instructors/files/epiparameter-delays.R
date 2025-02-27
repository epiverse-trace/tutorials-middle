
#' COMPLETE
#' - extract a serial interval for ebola
#' - extract natural parameters from the statistical distribution
#' - adapt it to the EpiNow2 interface

# packages ----------------------------------------------------------------

library(epiparameter)
library(EpiNow2)


# COMPLETE ---------------------------------------------------------------

# access one parameter ----------------------------------------------------

# ebola serial interval
ebola_serial <-
  epiparameter::epidist_db(
    disease = "ebola",
    epi_dist = "serial",
    single_epidist = TRUE
  )

ebola_serial

# extract distribution parameters --------------------------------------

ebola_serial_params <- epiparameter::get_parameters(ebola_serial)

# explore maximum value ---------------------------------------------------

plot(ebola_serial)

# adapt to EpiNow2 -----------------------------------------------------

EpiNow2::Gamma(
  shape = ebola_serial_params["shape"],
  scale = ebola_serial_params["scale"],
  max = 40
  )
