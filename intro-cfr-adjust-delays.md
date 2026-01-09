---
title: 'How to adjust the CFR for delays'
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

## Naive estimation of CFR

Consider a dataset containing daily incidence cases and deaths. 

<!--html_preserve--><div id="ykippoerxx" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#ykippoerxx table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#ykippoerxx thead, #ykippoerxx tbody, #ykippoerxx tfoot, #ykippoerxx tr, #ykippoerxx td, #ykippoerxx th {
  border-style: none;
}

#ykippoerxx p {
  margin: 0;
  padding: 0;
}

#ykippoerxx .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#ykippoerxx .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#ykippoerxx .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#ykippoerxx .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#ykippoerxx .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#ykippoerxx .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ykippoerxx .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#ykippoerxx .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#ykippoerxx .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#ykippoerxx .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#ykippoerxx .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#ykippoerxx .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#ykippoerxx .gt_spanner_row {
  border-bottom-style: hidden;
}

#ykippoerxx .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#ykippoerxx .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#ykippoerxx .gt_from_md > :first-child {
  margin-top: 0;
}

#ykippoerxx .gt_from_md > :last-child {
  margin-bottom: 0;
}

#ykippoerxx .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#ykippoerxx .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#ykippoerxx .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#ykippoerxx .gt_row_group_first td {
  border-top-width: 2px;
}

#ykippoerxx .gt_row_group_first th {
  border-top-width: 2px;
}

#ykippoerxx .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#ykippoerxx .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#ykippoerxx .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#ykippoerxx .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ykippoerxx .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#ykippoerxx .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#ykippoerxx .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#ykippoerxx .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#ykippoerxx .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ykippoerxx .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#ykippoerxx .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#ykippoerxx .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#ykippoerxx .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#ykippoerxx .gt_left {
  text-align: left;
}

#ykippoerxx .gt_center {
  text-align: center;
}

#ykippoerxx .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#ykippoerxx .gt_font_normal {
  font-weight: normal;
}

#ykippoerxx .gt_font_bold {
  font-weight: bold;
}

#ykippoerxx .gt_font_italic {
  font-style: italic;
}

#ykippoerxx .gt_super {
  font-size: 65%;
}

#ykippoerxx .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#ykippoerxx .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#ykippoerxx .gt_indent_1 {
  text-indent: 5px;
}

#ykippoerxx .gt_indent_2 {
  text-indent: 10px;
}

#ykippoerxx .gt_indent_3 {
  text-indent: 15px;
}

#ykippoerxx .gt_indent_4 {
  text-indent: 20px;
}

#ykippoerxx .gt_indent_5 {
  text-indent: 25px;
}

#ykippoerxx .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#ykippoerxx div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="time">Time</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="cases">Cases</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="deaths">Deaths</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="time" class="gt_row gt_right">0</td>
<td headers="cases" class="gt_row gt_right">3</td>
<td headers="deaths" class="gt_row gt_right">1</td></tr>
    <tr><td headers="time" class="gt_row gt_right">1</td>
<td headers="cases" class="gt_row gt_right">1</td>
<td headers="deaths" class="gt_row gt_right">0</td></tr>
    <tr><td headers="time" class="gt_row gt_right">2</td>
<td headers="cases" class="gt_row gt_right">3</td>
<td headers="deaths" class="gt_row gt_right">0</td></tr>
    <tr><td headers="time" class="gt_row gt_right">3</td>
<td headers="cases" class="gt_row gt_right">2</td>
<td headers="deaths" class="gt_row gt_right">0</td></tr>
  </tbody>
  
</table>
</div><!--/html_preserve-->

When examining their cumulative distributions (as illustrated in the figure below), we may wish to estimate the case fatality rate (CFR).

<img src="fig/intro-cfr-adjust-delays-rendered-unnamed-chunk-2-1.png" alt="" style="display: block; margin: auto;" />


The naive estimate of CFR, denoted as $b_t$, is calculated as the ratio of cumulative deaths $D_t$ to cumulative cases $C_t$ at time $t$:

$$b_t = \frac{D_t}{C_t} $$

Applying this formula directly to our dataset yields the $b_t$ values shown in the figure below.

<img src="fig/intro-cfr-adjust-delays-rendered-unnamed-chunk-3-1.png" alt="" style="display: block; margin: auto;" />

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


Then the unbiased CFR would be

$$ b_t = p_t \times u_t, \text{where} \;\; u_t = \frac{\sum\limits_{i=0}^{t}\sum\limits_{j=0}^{\infty}c_{i}f_{i-j}}{\sum\limits_{i=0}^{t}c_i}$$

If fact $u_t$ is called the **underestimation factor**, and the true  proportion of confirmed cases to die from the infection is then given by:

$$ p_t = b_t\frac{\sum\limits_{i=0}^{t}c_i}{\sum\limits_{i=0}^{t}\sum\limits_{j=0}^{\infty}c_{i}f_{i-j}}.$$

In practice, the delay distribution $f_s$ is estimated from samples of onset-to-outcome data. However, when deaths are few or absent during the early stages of an outbreak, assumptions about $f_s$ must be made based on literature from previous outbreaks of the same or similar diseases.

For example, suppose we have obtained the onset-to-outcome distribution for the dataset in our example. This distribution, shown in the figure below, characterizes the probability of death occurring $s$ days after case confirmation.

<img src="fig/intro-cfr-adjust-delays-rendered-unnamed-chunk-4-1.png" alt="" style="display: block; margin: auto;" />

Given that the equations are applied to discrete count data, such as daily case and death counts, $f_s$ denotes the associated Probability Mass Function (PMF).

Then we can use to produce estimated for $p_t$ as follows:

### Day 0

At $t = 0$ we observe $C_0 = 3, D_0 = 1$, giving a naive estimate $b_0 = \frac{1}{3}$. However, accounting for delays, the expected number of deaths by day 0 is

$$
\begin{equation}
\begin{split}
D_0 & = p_0 \times \sum_{i=0}^{0} \sum_{j=0}^{i} c_i f_{j-j} \\ 
& = p_0 \times \left( c_0 \times f_0 \right) \\ 
& = p_0 \times 3 \times 0.2 \\ 
& = p_0 \times 0.6 
\end{split}
\end{equation}
$$ 

where $p_0$ represents the true CFR. The factor $3 \times 0.2 = 0.6$ represents the expected proportion of cases with known outcomes by day 0, given the delay distribution. Hence

$$
b_0 = \frac{D_0}{C_0} = \frac{p_0 \times 0.6}{3}
$$

The understimation factor $u_0 = \frac{0.6}{3} = 0.2$ indicates that $b_0$ is only 20% of the true value $p_0$.

Solving for $p_0$, using the fact that $b_0 = \frac{1}{3}$, gives

$$
\Rightarrow p_0 = \frac{b_0 \times 3}{0.6} = \frac{1}{0.6} = 1.67
$$

### Day 1

At $t = 1$ we observe $C_1 = 4, D_1 = 1$, giving a naive estimate $b_1 = \frac{1}{4}$. 

Accounting for delays, the expected number of deaths by day 1 is

$$
\begin{equation}
\begin{split}
D_1 & = p_1 \times \sum_{i=1}^{1} \sum_{j=0}^{i} c_i f_{i-j} \\ 
& = p_1 \times \left[ c_1 \times f_0 + c_0 \times (f_0 + f_1) \right] \\ 
& = p_1 \times \left[ 1 \times 0.2 + 3 \times (0.4 + 0.2) \right] \\ 
& = p_1 \times 2
\end{split}
\end{equation}
$$

Then

$$
b_1 = \frac{D_1}{C_1} = \frac{p_1 \times 2}{4}
$$

The understimation factor $u_1 = \frac{2}{4} = 0.5$ indicates that $b_1$ is only 50% of the true value $p_1$.

Solving for $p_1$, gives

$$
\Rightarrow p_1 = \frac{b_1 \times 4}{2} = \frac{1}{2} = 0.5
$$

### Day 2

At $t = 2$ we observe $C_2 = 7, D_2 = 1$, giving a naive estimate $b_2 = \frac{1}{7}$. 

Accounting for delays, the expected number of deaths by day 2 is

$$
\begin{equation}
\begin{split}
D_2 & = p_2 \times \sum_{i=1}^{2} \sum_{j=0}^{i} c_i f_{i-j} \\ 
& = p_2 \times \Big[ c_2 \times f_0 + c_1 \times (f_0 + f_1) + c_0 \times (f_0 + f_1 + f_2) \Big] \\ 
& = p_2 \times \Big[ 3 \times 0.2 + 1 \times (0.4 + 0.2) + 3 \times (0.2 + 0.4 + 0.3) \Big] \\ 
& = p_2 \times 3.9
\end{split}
\end{equation}
$$

Then

$$
b_2 = \frac{D_2}{C_2} = \frac{p_2 \times 3.9}{7}
$$

The understimation factor $u_2 = \frac{3.9}{7} = 0.56$ indicates that $b_2$ is only 56% of the true value $p_2$.

Solving for $p_2$, gives

$$
\Rightarrow p_2 = \frac{b_2 \times 7}{3.9} = \frac{1}{3.9} = 0.26
$$

:::: challenge
## Can you do this?

- Calculate $p_t$ at time $t = 3$.

::: solution

At $t = 3$ we observe $C_3 = 9, D_3 = 1$, giving a naive estimate $b_3 = \frac{1}{9}$. 

Accounting for delays, the expected number of deaths by day 3 is

$$
\begin{equation}
\begin{split}
D_3 & = p_3 \times \sum_{i=1}^{3} \sum_{j=0}^{i} c_i f_{i-j} \\ 
& = p_3 \times \Big[ c_3 \times f_0 + c_2 \times (f_0 + f_1) + c_1 \times (f_0 + f_1 + f_2) + c_0 \times (f_0 + f_1 + f_2 + f_3) \Big] \\ 
& = p_3 \times \Big[ 2 \times 0.2 + 3 \times (0.2 + 0.4) + 1 \times (0.2 + 0.4 + 0.3) + 3 \times (0.2 + 0.4 + 0.3 + 0.1) \Big] \\ 
& = p_3 \times 6.1
\end{split}
\end{equation}
$$

Then

$$
b_3 = \frac{D_3}{C_3} = \frac{p_3 \times 6.1}{9}
$$

The understimation factor $u_3 = \frac{6.1}{9} = 0.68$ indicates that $b_3$ is only 68% of the true value $p_3$.

Solving for $p_3$, gives

$$
\Rightarrow p_2 = \frac{b_3 \times 9}{6.1} = \frac{1}{6.1} = 0.16
$$

:::

:::::


Once we calculate the delay-adjusted CFR for $t = 0,2,..., 3$, we can draw its curve, as shown in the figure below.

<img src="fig/intro-cfr-adjust-delays-rendered-unnamed-chunk-5-1.png" alt="" style="display: block; margin: auto;" />

::::: challenge

## Naive vs adjusted CFR

- What differences do you notice between the delay-adjusted CFR and the naive CFR?

::: hint

This figure may give you a clue

<img src="fig/intro-cfr-adjust-delays-rendered-unnamed-chunk-6-1.png" alt="" style="display: block; margin: auto;" />

:::
::: solution

The naive estimate can underestimate the CFR value at the early stages of the epidemic. 

:::
:::::

::::::::::::::::::::::::::::::::::::: keypoints 

- Understand how delays are accounted for {cfr}

::::::::::::::::::::::::::::::::::::::::::::::::
