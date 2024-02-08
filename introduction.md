---
title: 'Outbreak analytics pipelines'
teaching: 10
exercises: 2
editor_options: 
  chunk_output_type: console
---

:::::::::::::::::::::::::::::::::::::: questions 

- Why use R packages for Outbreak analytics?
- What can we do to analyse our outbreak data?
- How can I start doing Outbreak Analytics with R?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain our vision on the need for outbreak analytics R packages. 
- Share our strategy to create R packages into an outbreak analytics pipeline.
- Define our plan to start your learning path in outbreak analytics with R.

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: prereq

## Prerequisites

This episode requires you to be familiar with:

**Data science** : Basic programming with R.

**Epidemic theory** : Reproduction number.

:::::::::::::::::::::::::::::::::

## Why to use R packages for Outbreak analytics?

Outbreaks appear with different diseases and in different contexts, but what all of them have in common are the key public health questions ([Cori et al. 2017](https://royalsocietypublishing.org/doi/10.1098/rstb.2016.0371#d1e605)).

Is the epidemic going to take off? Is it under control? How much effort will be needed to control it? We can answer them by _quantifying the transmissibility_ of the disease. The most used parameter for this is the reproduction number ($R$), the average number of secondary infections caused by a typical primary case in the population
of interest ([Prism, 2016](http://prism.edu.au/publications/prism-modeling-guideline/)). We can intuitively interpret it as: 

- if $R>1$, the epidemic is likely to grow,
- if $R<1$, the epidemic is likely to decline.

We can estimate the reproduction number by initially using two __data inputs__: the incidence of reported cases and the [generation time](../learners/reference.md#generationtime) distribution. But to calculate it, we must apply the appropriate mathematical models written in code with the required computational methods. That is not enough! Following _good practices_, the code we write should be peer-reviewed and contain internal tests to double-check that we are getting the estimates we expect. Imagine rewriting all of it during a health emergency!

In R, the fundamental unit of shareable code is the _package_. A package bundles together code, data, documentation, and tests and is easy to share with others ([Wickham and Bryan, 2023](https://r-pkgs.org/introduction.html)). We, as epidemiologists, can contribute to their collaborative maintenance as a community to perform less error-prone data analysis pipelines.

::::::::::::::::::::::::::::::::: discussion

### Questions to think about

Remember your last experience with outbreak data and reflect on these questions:

- What data sources did you need to understand the outbreak?
- How did you get access to that data?
- Is that analysis pipeline you followed reusable for the next response?

Reflect on your experiences.

:::::::::::::::::::::::::::::::::::::::::::


## Example: Quantify transmission

The `{EpiNow2}` package provides a three-step solution to _quantify the transmissibility_. Let's see how to do this with a minimal example. First, load the package:


```r
library(EpiNow2)
```

### First, get your case data

Case incidence data must be stored in a data frame with the observed number of cases per day. We can read an example from the package:


```r
example_confirmed
```

```{.output}
           date confirm
         <Date>   <num>
  1: 2020-02-22      14
  2: 2020-02-23      62
  3: 2020-02-24      53
  4: 2020-02-25      97
  5: 2020-02-26      93
 ---                   
126: 2020-06-26     296
127: 2020-06-27     255
128: 2020-06-28     175
129: 2020-06-29     174
130: 2020-06-30     126
```

### Then, set the generation time

Not all primary cases have the same probability of generating a secondary case. The onset and cessation of [infectiousness](../learners/reference.md#infectiousness) may occur gradually. For `{EpiNow2}`, we can specify it as a probability `distribution` with `mean`, standard deviation `sd`, and maximum value `max`:


```r
generation_time <- dist_spec(
  mean = 3.6,
  sd = 3.1,
  max = 20,
  distribution = "lognormal"
)
```

### Let's calculate the reproduction number!

In the `epinow()` function we can add:

- the `reported_cases` data frame, 
- the `generation_time` delay distribution, and 
- the computation `stan` parameters for this calculation:


```r
epinow_estimates <- epinow(
  # cases
  reported_cases = example_confirmed[1:60],
  # delays
  generation_time = generation_time_opts(generation_time),
  # computation
  stan = stan_opts(
    cores = 4, samples = 1000, chains = 3,
    control = list(adapt_delta = 0.99)
  )
)
```

```{.output}
WARN [2024-02-08 10:18:42] epinow: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
Running the chains for more iterations may help. See
https://mc-stan.org/misc/warnings.html#bulk-ess - 
```

As an output, we get the time-varying (or [effective](../learners/reference.md#effectiverepro)) reproduction number, as well as the cases by date of report and date of infection:


```r
base::plot(epinow_estimates)
```

<img src="fig/introduction-rendered-unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

::::::::::::::::: callout

### Is this $Rt$ estimation biased?

Review [Gostic et al., 2020](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1008409) about what additional adjustments this estimation requires to avoid false precision in $Rt$. 

:::::::::::::::::::::::::

## The problem!

However, _quantifying the transmissibility_ during a real-life outbreak response is more challenging than this example!

Usually, we receive outbreak data in non-standard formats, requiring specific steps and taking the most time to prepare usable data inputs. Some of them are:

- Read delay distributions from the literature
- Read and clean case data
- Validate your line list
- Describe case data

And this is not the end. After _quantifying transmissibility_ we need to answer more key public health questions like: What is the attack rate we expect? What would be the impact of a given intervention? We can use the reproduction number and other outputs as new inputs for complementary tasks. For example:

- Estimate severity
- Create short-term forecast
- Simulate transmission scenarios
- Compare interventions

So, all these tasks can be interconnected in a pipeline:

![The outbreak analytics pipeline.](https://epiverse-trace.github.io/task_pipeline-minimal.svg)

## What can we do?

Our strategy is gradually incorporating specialised R packages into our traditional analysis pipeline. These packages should fill the gaps in these epidemiology-specific tasks in response to outbreaks. 

Epiverse-TRACE's aim is to provide a software ecosystem for outbreak analytics. We support the development of software pieces, make the existing ones interoperable for the user experience, and stimulate a community of practice.

![](fig/pkgs-hexlogos.png)

## How can I start?

Our plan for these tutorials is to introduce key solutions from packages in all the tasks before and after the _Quantify transmission_ task, plus the required theory concepts to interpret modelling outputs and make rigorous conclusions.

- In the first set of episodes, you will learn how to optimise the reading of delay distributions and cleaning of case data to input them into the _Quantify transmission_ task. These preliminary tasks are the __Early tasks__. These include packages like `{readepi}`, `{cleanepi}`, `{linelist}`, `{epiparameter}`, and `{episoap}`.

- Then, we will get deeper into the packages and required theory to _Quantify transmission_ and perform more real-time analysis tasks next to it. These are the __Middle tasks__. This includes `{EpiNow2}`, `{cfr}`, `{epichains}`, and `{superspreading}`.

- Lastly, we will use _Quantify transmission_ data outputs to compare it to other indicators and simulate epidemic scenarios as part of the __Late tasks__. This includes `{finalsize}`, `{epidemics}`, and `{scenarios}`.


::::::::::::::::::::::::::::::::::::: keypoints 

- Our vision is to have pipelines of R packages for outbreak analytics.
- Our strategy is to create interconnected tasks to get relevant outputs for public health questions.
- We plan to introduce package solutions and theory bits for each of the tasks in the outbreak analytics pipeline.

::::::::::::::::::::::::::::::::::::::::::::::::

