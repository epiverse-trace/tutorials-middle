# questions for PR review

#' - other disease instead of COVID-19 to make a
#' valid usage of the serial interval instead of
#' the generation interval?
#'
#' look for a symptomatic transmission disease!

epidist_db(disease = "all") %>%
  list_distributions() %>%
  as_tibble() %>%
  count(disease,epi_distribution) %>%
  group_by(disease) %>%
  filter(magrittr::is_in(c("serial interval"),epi_distribution)) %>%
  ungroup() %>%
  print(n=Inf)

#' we have
#' - generation and serial for influenza
#' - serial only for COVID-19, MERS, Mpox, Malburg, Ebola (+ incubation period)
#'
#' now from these, which ones have symptomatic transmission?!!!


# ebola -------------------------------------------------------------------

epidist_db(
  disease = "Ebola"
) %>%
  list_distributions()

epidist_db(
  disease = "Ebola",
  epi_dist = "serial interval",
  single_epidist = TRUE
)

epidist_db(
  disease = "Ebola",
  epi_dist = "incubation period",
  single_epidist = TRUE
)

# [* pending to share] covid -------------------------------------------------------------------

library(epiparameter)
library(tidyverse)

# how to know to differentiate them by sample size?
epidist_db(disease = "covid",epi_dist = "incubation",author = "stephen") %>%
  list_distributions()

multidist <- epidist_db(disease = "covid",epi_dist = "incubation",author = "stephen")

# str(multidist)
multidist[[1]]$metadata$sample_size
multidist[[4]]$metadata$sample_size

library(epiparameter)
library(tidyverse)

singledist <-
  epidist_db(
    disease = "covid",
    epi_dist = "incubation",
    author = "stephen",
    single_epidist = T
  )

singledist$metadata$sample_size

# from epiparameter -------------------------------------------------------
plot(singledist,day_range = 0:25)
singledist$summary_stats$median
singledist$summary_stats$median_ci_limits
stats::quantile(singledist,p = 0.975)
#' 97.5% of those who develop symptoms
#' will do so within 23.9 days of infection.
stats::quantile(singledist,p = 0.99)
#' 100 out of every 10,000 cases
#' will develop symptoms after 35 days
#' of active monitoring

# from paper --------------------------------------------------------------
epiparameter::cdf(singledist,q = 11.5)
#' 90.2% of those who develop symptoms
#' will do so within 11.5 days of infection.
incubation_cdf <- epiparameter::cdf(singledist,q = 14)
(1-incubation_cdf)*10000
#' 708 out of every 10,000 cases
#' will develop symptoms after 14 days
#' of active monitoring

# from distribution functions ---------------------------------------------
stats::quantile(singledist,p = 0.5) # median
stats::quantile(singledist,p = 0.99)

tibble(value = 0:30) %>%
  mutate(proportion = epiparameter::cdf(singledist, q = value)) %>%
  # mutate(proportion = exp(proportion)) %>%
  ggplot(aes(value,proportion)) +
  geom_point()

# singledist$prob_dist
# singledist$uncertainty$dispersion$ci_limits


# explore influenza -------------------------------------------------------

epidist_db(disease = "influenza")

epidist_db(disease = "influenza",epi_dist = "serial") %>% plot()
epidist_db(disease = "influenza",epi_dist = "generation") %>% plot()

epidist_db(disease = "mers")

epidist_db(disease = "sars")

# explore filtering arguments ---------------------------------------------

library(epiparameter)
library(tidyverse)
epidist_db(disease = "covid",epi_dist = "serial") %>%
  list_distributions()
epidist_db(disease = "covid",epi_dist = "serial",author = "Lin") %>%
  list_distributions()
epidist_db(disease = "covid",epi_dist = "serial",author = "Lin") %>%
  plot(xlim = c(-2,10))
epidist_db(disease = "covid",epi_dist = "serial",author = "Hiroshi",single_epidist = T) %>%
  plot()

# [* pending to report] ---------------------------------------------------


#' case sentitivity
#'
#' - se usan cadenas o palabras clave?
#' para algunas pero no para todas?
#'
epiparameter::epidist_db(disease = "eBola") %>%
  epiparameter::list_distributions() %>%
  as_tibble()
epidist_db(epi_dist = "SERIAL") %>%
  list_distributions() %>%
  as_tibble() %>%
  count(disease,epi_distribution)
epidist_db(epi_dist = "SERI") %>%
  list_distributions() %>%
  as_tibble() %>%
  count(disease,epi_distribution)
epidist_db(epi_dist = "gen") %>%
  list_distributions()
epidist_db(epi_dist = "interval") %>%
  list_distributions() %>%
  as_tibble() %>%
  count(disease,epi_distribution)
epidist_db(epi_dist = "tion") %>%
  list_distributions() %>%
  as_tibble() %>%
  count(disease,epi_distribution)
epidist_db(epi_dist = "notification to death") %>%
  list_distributions() %>%
  as_tibble() %>%
  count(disease,epi_distribution)


# extra -------------------------------------------------------------------

epidist_db(
  disease = "sars"
)


# all ---------------------------------------------------------------------

epidist_db(disease = "all") %>% list_distributions() %>%
  as_tibble() %>%
  distinct(epi_distribution)


# [* pregunta] ------------------------------------------------------------

# is it possible to get the distribution name from epidist?

covid_serialint <-
  epiparameter::epidist_db(
    disease = "covid",
    epi_dist = "serial",
    author = "Nishiura",
    single_epidist = T
  )

covid_serialint$prob_dist


# reprex ------------------------------------------------------------------

library(epiparameter)
library(distributional)

covid_serialint <-
  epiparameter::epidist_db(
    disease = "covid",
    epi_dist = "serial",
    author = "Nishiura",
    single_epidist = T
  )

covid_serialint

# How to read this notation?

covid_serialint$prob_dist

# This object is class `distribution`

class(covid_serialint$prob_dist)

# so a reference would be:
# ?distributional::dist_lognormal()
# is there a handy way to interpret this?

# just in case
# if we unlist the parameters, the output is reproducible
covid_serialint_parameters <- unlist(covid_serialint$prob_dist)

distributional::dist_lognormal(
  mu = covid_serialint_parameters[1],
  sigma = covid_serialint_parameters[2]
)


# reprex ------------------------------------------------------------------

library(epiparameter)

incubation <-
  epiparameter::epidist_db(
    disease = "covid",
    epi_dist = "incubation",
    single_epidist = T
  )

plot(incubation)
# x: incubation period (days)

serial <-
  epiparameter::epidist_db(
    disease = "covid",
    epi_dist = "serial",
    single_epidist = T
  )

plot(serial)
# y: serial interval (days)


# reprex ------------------------------------------------------------------

# if
# sem = standard error of the mean = standard deviation of the sample means distribution
# sd = standard deviation of the sample distribution
# n = sample size
# 1.96 = critical value for a significant level of 5% from qnorm(p = 0.975)
# then
# sem = sd / sqrt(n)
# 95%ci = mean +- 1.96*sem
# precision = 1.96*sem
#
# for the mean_sd in {EpiNow2}
# we need the standard deviation of the mean distribution
# represented a Bayesian prior which is assumed to be normally distributed with a given sd
# then,
# for the mean_sd we can use the sem
# thus,
# with the 95% ci width (mean_ci_width)
# mean_ci_width = 2 * precision
# mean_ci_width = 2 * 1.96 * sem
# we have
# sem = (mean_ci_width / (2 * 1.96))

covid_lnorm <-
  epiparameter::epidist_db(
    disease = "covid",
    epi_dist = "serial",
    author = "Nishiura",
    single_epidist = T
  )

covid_lnorm

# mean
covid_lnorm$summary_stats$mean

# mean_ci width
covid_lnorm$summary_stats$mean_ci
covid_lnorm$summary_stats$mean_ci_limits
mean_ci_limits_num <- covid_lnorm$summary_stats$mean_ci_limits
mean_ci_width <- mean_ci_limits_num[2] - mean_ci_limits_num[1]
mean_ci_width

# from paper
covid_lnorm_sample <- covid_lnorm$metadata$sample_size
covid_lnorm_sample
# stats::qt(p = 0.975,df = covid_lnorm_sample-1)
# stats::qt(p = 0.025,df = covid_lnorm_sample-1)
t_095 <- stats::qt(p = 0.975,df = covid_lnorm_sample-1)

# mean_sd
covid_lnorm_mean_sd <- (mean_ci_width / 2*t_095)
covid_lnorm_mean_sd

# sd_sd
covid_lnorm$summary_stats$sd
sd_ci_limits_num <- covid_lnorm$summary_stats$sd_ci_limits
sd_ci_width <- sd_ci_limits_num[2] - sd_ci_limits_num[1]
sd_ci_width
covid_lnorm_sd_sd <- (sd_ci_width / 2*t_095)
covid_lnorm_sd_sd



# reprex epidemics --------------------------------------------------------

library(tidyverse)
pak::lib_status() %>%
  filter(package == "epidemics") %>%
  select(remotesha)



# on censoring or truncation ----------------------------------------------


# However, this still propagates potential biases like
#
# - censoring bias (short periods)
# - reporting bias (recent contacts)


# install -----------------------------------------------------------------

# install_version(
#   package = "EpiNow2", version = "1.4.0",
#   repos = "http://cran.us.r-project.org"
# )


# backup ------------------------------------------------------------------

# R probability functions for the normal distribution
#
# For each probability distribution in R there are four basic probability functions. Each of R's probability functions begins with one of four prefixes—d, p, q, or r—followed by a root name that identifies the probability distribution. For the normal distribution the root name is "norm". The meaning of these prefixes is as follows.
#
#     d is for "density" and the corresponding function returns the value of the probability density function (continuous distributions) or the probability mass function (discrete distributions).
#     p is for "probability" and the corresponding function returns a value from the cumulative distribution function.
#     q is for "quantile" and the corresponding function returns a value from the inverse cumulative distribution function, also know as the quantile function.
#     r is for "random" and the corresponding function returns a randomly drawn value from the given distribution.
#
# To better understand what these functions do I'll focus on the four probability functions for the normal distribution: dnorm, pnorm, qnorm, and rnorm. Fig. 5 illustrates the relationships among these four functions.
#
# fig. 5
# Fig. 5  The four probability functions for the normal distribution  R code for Fig. 5
#
# dnorm is the normal probability density function. Without any further arguments it returns the density of the standard normal distribution (mean 0 and standard deviation 1). If you plot dnorm(x) over a range of x-values you obtain the usual bell-shaped curve of the normal distribution. In Fig. 5, the value of dnorm(2) is indicated by the height of the vertical red line segment. It's the y-coordinate of the normal curve when x = 2. Keep in mind that density values are not probabilities. To obtain probabilities from densities one has to integrate the density function over an interval. Alternatively for a very small interval, say one of width Δx, if f(x) is a probability density function, then we can approximate the probability of x being in that interval as follows.
#
# probability from a density
#
# pnorm is the cumulative distribution function for the normal distribution. By definition pnorm(x) = P(X ≤ x) which is the area under the normal density curve to the left of x. Fig. 5 shows pnorm(2)as the shaded area under the normal density curve to the left of x = 2. As is indicated on the figure, this area is 0.977. So the probability that a standard normal random variable takes on a value less than or equal to 2 is 0.977.
#
# qnorm is the quantile function of the standard normal distribution. If qnorm(x) = k then k is the value such that P(X ≤ k) = x . qnorm is the inverse function for pnorm. From Fig. 5 we have, qnorm(0.977) = qnorm(pnorm(2)) = 2.
#
# rnorm generates random values from a standard normal distribution. The only required argument is a number specifying the number of realizations of a normal random variable to produce. Fig. 5 illustrates rnorm(50), the locations of 50 random realizations from the standard normal distribution, jittered slightly to prevent overlap.
#
# To obtain normal distributions other than the standard normal, all four normal functions support the additional arguments mean and sd for the mean and standard deviation of the normal distribution. For instance, dnorm(x, mean=4, sd=2) is a normal density with mean 4 and standard deviation 2. Notice that R parameterizes the normal distribution in terms of the standard deviation rather than the variance.



# reporting bias ----------------------------------------------------------

reporting_delay <- dist_spec(
  mean = convert_to_logmean(2, 1),
  sd = convert_to_logsd(2, 1),
  max = 10, distribution = "lognormal"
)

epinow_estimates <- epinow(
  # cases
  reported_cases = example_confirmed[1:60],
  # delays
  generation_time = generation_time_opts(generation_time),
  delays = delay_opts(
    incubation_period + reporting_delay
  ),
  # computation
  stan = stan_opts(
    cores = 4, samples = 1000, chains = 3,
    control = list(adapt_delta = 0.99)
  )
)
