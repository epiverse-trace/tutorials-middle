---
title: Setup
---

## Motivation

**Outbreaks** of infectious diseases can appear as a result of different pathogens, and in different contexts, but they typically lead to similar public health questions, from understanding patterns of transmission and severity to examining the effect of control measures ([Cori et al. 2017](https://royalsocietypublishing.org/doi/10.1098/rstb.2016.0371#d1e605)). We can relate each of these public health questions to a series of outbreak data analysis tasks. The more efficiently and reliably we can perform these tasks, the faster and more accurately we can answer the underlying questions.

Epiverse-TRACE aims to provide a software ecosystem for [**outbreak analytics**](reference.md#outbreakanalytics) with integrated, generalisable and scalable community-driven software. We support the development of new R packages, help link together existing tools to make them more user-friendly, and contribute to a community of practice, spanning field epidemiologists, data scientists, lab researchers, health agency analysts, software engineers and more.

### Epiverse-TRACE tutorials

Our tutorials are built around an outbreak analysis pipeline split into three stages: **Early tasks**, **Middle tasks** and **Late tasks**. The outputs of tasks completed in earlier stages commonly feed into the tasks required for later ones.


![An overview of the tutorial topics](https://epiverse-trace.github.io/task_pipeline-minimal.svg)

Each task has its tutorial website and each tutorial website consists of a set of episodes covering different topics.

| [Early task tutorials ➠](https://epiverse-trace.github.io/tutorials-early/) | [Middle task tutorials ➠](https://epiverse-trace.github.io/tutorials-middle) | [Late task tutorials ➠](https://epiverse-trace.github.io/tutorials-late/) |
|---|---|---|
| Read and clean case data, and make linelist | Real-time analysis and forecasting | Scenario modelling |
| Read, clean and validate case data, convert linelist data to incidence for visualization. | Access delay distributions and estimate transmission metrics, forecast cases, estimate severity and superspreading. | Simulate disease spread and investigate interventions. |

Each episode contains:

+ **Overview**: describes what questions will be answered and the objectives of the episode.
+ **Prerequisites**: describes what episodes/packages ideally need to be covered before the current episode.
+ **Example R code**: example R code so you can work through the episodes on your own computer.
+ **Challenges**: challenges that can be completed to test your understanding.
+ **Explainers**: boxes to enhance your understanding of mathematical and modelling concepts.

Also check out the [glossary](./reference.md) for any terms you may be unfamiliar with.

### Epiverse-TRACE R packages

Our strategy is to gradually incorporate specialised **R packages** into a traditional analysis pipeline. These packages should fill the gaps in these epidemiology-specific tasks in response to outbreaks.

![In **R**, the fundamental unit of shareable code is the **package**. A package bundles together code, data, documentation, and tests and is easy to share with others ([Wickham and Bryan, 2023](https://r-pkgs.org/introduction.html))](episodes/fig/pkgs-hexlogos-2.png)

:::::::::::::::::::::::::::: prereq

This content assumes intermediate R knowledge. This tutorials are for you if:

- You can read data into R, transform and reshape data, and make a wide variety of graphs
- You are familiar with functions from `{dplyr}`, `{tidyr}`, and `{ggplot2}`
- You can use the magrittr pipe `%>%` and/or native pipe `|>`.


We expect learners to have some exposure to basic Statistical, Mathematical and Epidemic theory concepts, but NOT intermediate or expert familiarity with modeling.

::::::::::::::::::::::::::::

## Software Setup

Follow these two steps:

### 1. Install or upgrade R and RStudio

R and RStudio are two separate pieces of software:

* **R** is a programming language and software used to run code written in R.
* **RStudio** is an integrated development environment (IDE) that makes using R easier. We recommend to use RStudio to interact with R.

To install R and RStudio, follow these instructions <https://posit.co/download/rstudio-desktop/>.

::::::::::::::::::::::::::::: callout

### Already installed?

Hold on: This is a great time to make sure your R installation is current.

This tutorial requires **R version 4.0.0 or later**.

:::::::::::::::::::::::::::::

To check if your R version is up to date:

- In RStudio your R version will be printed in [the console window](https://docs.posit.co/ide/user/ide/guide/code/console.html). Or run `sessionInfo()` there.

- **To update R**, download and install the latest version from the [R project website](https://cran.rstudio.com/) for your operating system.

  - After installing a new version, you will have to reinstall all your packages with the new version.

  - For Windows, the `{installr}` package can upgrade your R version and migrate your package library.

- **To update RStudio**, open RStudio and click on
`Help > Check for Updates`. If a new version is available follow the
instructions on the screen.

::::::::::::::::::::::::::::: callout

### Check for Updates regularly

While this may sound scary, it is **far more common** to run into issues due to using out-of-date versions of R or R packages. Keeping up with the latest versions of R, RStudio, and any packages you regularly use is a good practice.

:::::::::::::::::::::::::::::

### 2. Check and Install Build Tools

Some packages require a complementary set of tools to build them.
Open RStudio and **copy and paste** the following code chunk into the 
[console window](https://docs.posit.co/ide/user/ide/guide/code/console.html),
then press the <kbd>Enter</kbd> (Windows and Linux) or <kbd>Return</kbd> (MacOS) to execute the command:

```r
if(!require("pkgbuild")) install.packages("pkgbuild")
pkgbuild::check_build_tools(debug = TRUE)
```

We expect a message like the one below:

```output
Your system is ready to build packages!
```

If the build tools are not available, this will trigger an automated install.

1. Run the command in the console.
2. Don’t interrupt it—wait until R prints the confirmation message.
3. Once that’s done, restart your R session (or just restart RStudio) to ensure the changes take effect.

If the automatic installation **does not** work, you can manually install them according to your operating system.

::::::::::::::::::::::::::::: tab

### Windows

Windows users will need a working installation of `Rtools` in order to build the package from source.  
`Rtools` is not an R package, but a software you need to download and install.
We suggest you to follow:

- **Install `Rtools`**. Download the `Rtools` installer from <https://cran.r-project.org/bin/windows/Rtools/>. Install with default selections.
- Close and reopen RStudio so it can recognize the new installation.

### Mac

Mac users require two additional steps as detailed in this [guide to Configuring C Toolchain for Mac](https://github.com/stan-dev/rstan/wiki/Configuring-C---Toolchain-for-Mac):

- Install and use [`macrtools`](https://mac.thecoatlessprofessor.com/macrtools/) to setup the C++ toolchain
- Enable some compiler optimizations.

### Linux

Linux users require specific details per distribution. Find them in this [guide to Configuring C Toolchain for Linux](https://github.com/stan-dev/rstan/wiki/Configuring-C-Toolchain-for-Linux).

:::::::::::::::::::::::::::::

::::::::::::: callout

### Environment Check

This step requires administrator privileges to install software.

If you do not have admin rights in your current environment:  

- Try running the tutorial on your **personal machine** where you have full access.  
- Use a **preconfigured development environment** (e.g. [Posit Cloud](https://posit.cloud/)).  
- Ask your **system administrator** to install the required software for you.  

:::::::::::::

### 3. Install the required R packages

<!--
During the tutorial, we will need a number of R packages. Packages contain useful R code written by other people. We will use packages from the [Epiverse-TRACE](https://epiverse-trace.github.io/).
-->

Open RStudio and **copy and paste** the following code chunk into the [console window](https://docs.posit.co/ide/user/ide/guide/code/console.html), then press the <kbd>Enter</kbd> (Windows and Linux) or <kbd>Return</kbd> (MacOS) to execute the command:

```r
# for episodes on access delays and quantify transmission

if(!require("pak")) install.packages("pak")

new_packages <- c(
  "EpiNow2",
  "epiparameter",
  "incidence2",
  "tidyverse"
)

pak::pkg_install(new_packages)
```

```r
# for episodes on forecast and severity

if(!require("pak")) install.packages("pak")

new_packages <- c(
  "EpiNow2",
  "cfr",
  "epiparameter",
  "incidence2",
  "outbreaks",
  "tidyverse"
)

pak::pkg_install(new_packages)
```

```r
# for episodes on superspreading and transmission chains

if(!require("pak")) install.packages("pak")

superspreading_packages <- c(
  "epicontacts",
  "fitdistrplus",
  "superspreading",
  "epichains",
  "epiparameter",
  "incidence2",
  "outbreaks",
  "tidyverse"
)

pak::pkg_install(superspreading_packages)
```

These installation steps could ask you `? Do you want to continue (Y/n)` write `Y` and press <kbd>Enter</kbd>.

::::::::::::::::::::::::::::: spoiler

### do you get an error with EpiNow2?

Windows users will need a working installation of `Rtools` in order to build the package from source. `Rtools` is not an R package, but a software you need to download and install. We suggest you to follow:

<!-- reference [these steps](http://jtleek.com/modules/01_DataScientistToolbox/02_10_rtools/#1) -->

1. **Verify `Rtools` installation**. You can do so by using Windows search across your system. Optionally, you can use `{devtools}` running:

```r
if(!require("devtools")) install.packages("devtools")
devtools::find_rtools()
```

If the result is `FALSE`, then you should do step 2.

2. **Install `Rtools`**. Download the `Rtools` installer from <https://cran.r-project.org/bin/windows/Rtools/>. Install with default selections.

3. **Verify `Rtools` installation**. Again, we can use `{devtools}`:

```r
if(!require("devtools")) install.packages("devtools")
devtools::find_rtools()
```

:::::::::::::::::::::::::::::

You should update **all of the packages** required for the tutorial, even if you installed them relatively recently. New versions bring improvements and important bug fixes.

When the installation has finished, you can try to load the packages by pasting the following code into the console:

```r
# for episodes on access delays and quantify transmission

library(EpiNow2)
library(epiparameter)
library(incidence2)
library(tidyverse)
```

```r
# for episodes on forecast and severity

library(EpiNow2)
library(cfr)
library(epiparameter)
library(incidence2)
library(outbreaks)
library(tidyverse)
```

```r
# for episodes on superspreading and transmission chains

library(epicontacts)
library(fitdistrplus)
library(superspreading)
library(epichains)
library(epiparameter)
library(incidence2)
library(outbreaks)
library(tidyverse)
```

If you do NOT see an error like `there is no package called ‘...’` you are good to go! If you do, [contact us](#your-questions)!

### 4. Watch and Read the pre-training material

:::::::::::::::::::::::::::: prereq

<!--
One paper introduction to Outbreak analytics:

- Polonsky JA, Baidjoe A, Kamvar ZN, Cori A, Durski K, Edmunds WJ, Eggo RM, 
Funk S, Kaiser L, Keating P, de Waroux OLP, Marks M, Moraga P, Morgan O, 
Nouvellet P, Ratnayake R, Roberts CH, Whitworth J, Jombart T. 
**Outbreak analytics: a developing data science for informing the response to emerging pathogens.** 
Philos Trans R Soc Lond B Biol Sci. 2019 Jul 8;374(1776):20180276. 
doi: 10.1098/rstb.2018.0276. PMID: 31104603; PMCID: PMC6558557.
-->

**Watch** three 5-minute video refreshers on statistical distributions:

- StatQuest with Josh Starmer (2017) 
**The Main Ideas behind Probability Distributions**, YouTube. 
Available at: <https://www.youtube.com/watch?v=oI3hZJqXJuc&t> 
<!--(Accessed: 30 October 2024).-->

<!--
- StatQuest with Josh Starmer (2015)
**Confidence Intervals, Clearly Explained!!!**, YouTube.
Available at: <https://www.youtube.com/watch?v=TqOeMYtOc1w>
(Accessed: 04 November 2024).
-->

- StatQuest with Josh Starmer (2018) 
**Probability is not Likelihood. Find out why!!!**, YouTube. 
Available at: <https://www.youtube.com/watch?v=pYxNSUDSFH4> 
<!--(Accessed: 30 October 2024).-->

- StatQuest with Josh Starmer (2017) 
**Maximum Likelihood, clearly explained!!!**, YouTube. 
Available at: <https://www.youtube.com/watch?v=XepXtl9YKwc>
<!--(Accessed: 30 October 2024).-->

<!--
- Weiss, J. (2012) 
**R probability functions for the normal distribution**, 
Lecture 13-Monday, October 8, 2012. 
Available at: <https://sakai.unc.edu/access/content/group/3d1eb92e-7848-4f55-90c3-7c72a54e7e43/public/docs/lectures/lecture13.htm#probfunc>
(Accessed: 30 October 2024). 
-->

<!--
**Read** a two-page paper introduction to Infectious Disease Modelling:

- Bjørnstad ON, Shea K, Krzywinski M, Altman N. 
**Modeling infectious epidemics.** 
Nat Methods. 2020 May;17(5):455-456. 
doi: 10.1038/s41592-020-0822-z. PMID: 32313223.
<https://www.nature.com/articles/s41592-020-0822-z>
-->

<!--
- Bjørnstad ON, Shea K, Krzywinski M, Altman N. 
**The SEIRS model for infectious disease dynamics.** 
Nat Methods. 2020 Jun;17(6):557-558. doi: 10.1038/s41592-020-0856-2.
<https://www.nature.com/articles/s41592-020-0856-2>
Erratum in: Nat Methods. 2021 Mar;18(3):321. PMID: 32499633.

- McVernon, J. et al. (2016) 
**A user’s Guide to Infectious Disease Modelling**, Prism. 
Available at: http://prism.edu.au/publications/prism-modeling-guideline/ 
(Accessed: 14 March 2024).
-->

::::::::::::::::::::::::::

## Data sets

### Download the data

We will download the data directly from R during the tutorial. However, if you are expecting problems with the network, it may be better to download the data beforehand and store it on your machine.

The data files for the tutorial can be downloaded manually here:

- <https://epiverse-trace.github.io/tutorials-middle/data/ebola_cases.csv>

- <https://epiverse-trace.github.io/tutorials-middle/data/sarscov2_cases_deaths.csv>

## Your Questions

If you need any assistance installing the software or have any other questions about this tutorial, please send an email to <andree.valle-campos@lshtm.ac.uk>
