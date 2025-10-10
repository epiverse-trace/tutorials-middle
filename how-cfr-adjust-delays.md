---
title: 'How CFR adjusts delays'
teaching: 15
exercises: 5
editor_options: 
  markdown: 
    wrap: 72
---

::: questions
-   How are delays adjust for when estimating CFR?
:::

::: objectives
-   Understand how delays are incorporated into severity estimation
-   Understand the underestimation factor
-   Understand the mechanisms behind `{cfr}`
:::

## Introduction

The `{cfr}` package accounts for onset-to-outcome delays to produce more
accurate estimates of case fatality risk (CFR). This document outlines
how these delays are incorporated and explains the underlying
mathematical framework that enables this adjustment.

## Naive estimation of $CFR$

Consider a dataset containing daily incidence cases and deaths. When examining their cumulative distributions (as illustrated in the figure below), we may wish to estimate the case fatality rate (CFR).

<img src="fig/how-cfr-adjust-delays-rendered-unnamed-chunk-1-1.png" style="display: block; margin: auto;" />


The naive estimate of CFR, denoted as $b_t$, is calculated as the ratio of cumulative deaths $D_t$ to cumulative cases $C_t$ at time $t$
$$b_t = \frac{D_t}{C_t} $$. 

Applying this formula directly to our dataset yields the $b_t$ values shown in the figure below.

<img src="fig/how-cfr-adjust-delays-rendered-unnamed-chunk-2-1.png" style="display: block; margin: auto;" />
This approach, while straightforward, does not account for the temporal lag between case reporting and death occurrence, which can lead to biased estimates (underestimates), particularly during the early stages of an outbreak or when case numbers are changing rapidly and many of them with unknown outcome.

## Unbiased CFR
To understand how delays affect the naive CFR estimate, we can express $C_t$ and $D_t$ as function of the incidences $c_t$.

The cumulative number of cases is simply the sum of all confirmed cases up to time $t$:
$$C_t = \sum\limits_{i=0}^{t}c_i.$$
However, the cumulative number of deaths represents a proportion of confirmed cases with known outcomes up to time $t$. This must account for the delay distribution between case confirmation and death

$$ D_t = p_t\times \sum\limits_{i=0}^{t}\sum\limits_{j=0}^{\infty}c_{i}f_{i-j}$$

where:

- $c_i=$ number of cases confirmed on day $i$
- $f_s$ = probability density function for the delay of $s$ days from case confirmation outcome
- $p_t$ = proportion of cases that result in death (true CFR) at time $t$


Then the un-biased CFR would be
$$ b_t = p_t*u_t, \text{where} \;\; u_t = \frac{\sum\limits_{i=0}^{t}\sum\limits_{j=0}^{\infty}c_{i}f_{i-j}}{\sum\limits_{i=0}^{t}c_i}$$
If fact $u_t$ is called the **underestimation factor**, and the true  proportion of confirmed cases to die from the infection is then given by:

$$ p_t = b_t\frac{\sum\limits_{i=0}^{t}c_i}{\sum\limits_{i=0}^{t}\sum\limits_{j=0}^{\infty}c_{i}f_{i-j}}.$$

In practice, the delay distribution $f_j$ is estimated from samples of onset-to-outcome data. However, when deaths are few or absent during the early stages of an outbreak, assumptions about $f_j$ must be made based on literature from previous outbreaks of the same or similar diseases.

For example, suppose we have obtained the onset-to-outcome distribution for the dataset in our example. This distribution, shown in the figure below, characterizes the probability of death occurring $j$ days after case confirmation.

<img src="fig/how-cfr-adjust-delays-rendered-unnamed-chunk-3-1.png" style="display: block; margin: auto;" />

Then we can use to produce estimated for $p_t$ as follows:

- $t = 1$: we observe $C_1 = 3, D_1 = 1$, giving a naive estimate $b_1 = \frac{1}{3}$. However, accounting for delays, the expected number of deaths by day 1 is

 $$ D_1 = p_1*\sum\limits_{i=0}^{1}\sum\limits_{j=0}^{i}c_{i}f_{j-j} = p_1*c_1*f_1= p_1*3*0.2 = 0.6*p_1 $$
 
 where $p_1$ represents the true CFR. The factor $3\times0.2=0.6$  represents the expected proportion of cases with known outcomes by day 1, given the delay distribution. Hence 
 $$ b_1 = \frac{D_1}{C_1} = \frac{p_1*0.6}{3}$$

Solving for $p_1$, using the fact that $b_1 =  \frac{1}{3}$, gives
$$\Rightarrow p_1 = \frac{b_1*3}{0.6} = \frac{1}{0.6} = 1.67 $$
- $t = 2$: we observe $C_2 = 4, D_2 = 1$, giving a naive estimate $b_2 = \frac{1}{4}$. 

Accounting for delays, the expected number of deaths by day 2 is
 $$ D_2 = p_2*\sum\limits_{i=1}^{2}\sum\limits_{j=0}^{i}c_{i}f_{i-j} = p_2\times [c_2*f_1 + c_1*(f_1+f_2)] = p_2 [1*0.2 + 3*(0.4+0.2)] = p_2*2 $$
Solving for $p_2$, gives
$$\Rightarrow p_2 = \frac{b_2*4}{2} = \frac{1}{2} = 0.5 $$
- $t = 3$: we observe $C_3 = 7, D_3 = 1$, giving a naive estimate $b_3 = \frac{1}{7}$. 

Accounting for delays, the expected number of deaths by day 3 is
 $$ D_3 = p_3*\sum\limits_{i=1}^{3}\sum\limits_{j=0}^{i}c_{i}f_{i-j} = p_3\times [c_3*f_1 + c_2*(f_1+f_2) + c_1*(f_1+f_2+f_3)] $$
 $$ \Rightarrow D_3 =  p_3\times[3*0.2 + 1*(0.4+0.2)+3*(0.2+0.4+0.3)] = p_3*3.9$$
Solving for $p_3$, gives
$$\Rightarrow p_3 = \frac{b_3*7}{3.9} = \frac{1}{3.9} = 0.26 $$

:::: challenge
## Can you do this?

- Calculate $p_t$ at time $t$.

::: solution

Apply the formula to get: 

- $t = 4$: we observe $C_4 = 9, D_4 = 1$, giving a naive estimate $b_4 = \frac{1}{9}$. 

Accounting for delays, the expected number of deaths by day 3 is
 $$ D_4 = p_4*\sum\limits_{i=1}^{4}\sum\limits_{j=0}^{i}c_{i}f_{i-j} = $$
 $$  = p_4\times [c_4*f_1 +c_3*(f_1 +f_2) + c_2*(f_1+f_2+f_3) + c_1*(f_1+f_2+f_3+f_4)] $$
 $$ =  p_4\times[2*0.2 + 3*(0.2+0.4)+1*(0.2+0.4+0.3) +3*(0.2+0.4+0.3+0.1)] = p_4*6.1$$
Solving for $p_4$, gives
$$\Rightarrow p_3 = \frac{b_4*9}{6.1} = \frac{1}{6.1} = 0.16 $$

:::

:::::


Once we calculate the delay-adjusted   $CFR$ for $t = 1,2,..., 4$, we can draw its curve, as shown in the figure below.

<img src="fig/how-cfr-adjust-delays-rendered-unnamed-chunk-4-1.png" style="display: block; margin: auto;" />

::::: challenge
## Naive vs adjusted $R_t$

- What differences do you notice between the delay-adjusted CFR and the naive CFR$?

::: hint

This figure may give you a clue

<img src="fig/how-cfr-adjust-delays-rendered-unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

:::
::: solution

The naive estimate can underestimate the CFR value at the early stages of the epidemic. 

:::
:::::
