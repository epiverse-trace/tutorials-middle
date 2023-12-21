---
title: 'Glossary of Terms: Epiverse-TRACE'
---

## A

[Airborne transmission]{#airborne}
: Individuals become infected via contact with infectious particles in the air. Examples include influenza and COVID-19. Atler et al. (2023) discuss about [factors and management procedures](https://www.ncbi.nlm.nih.gov/books/NBK531468/) of airborne transmission.

<!--  ## B -->

## C

[Contact matrix]{#contact}
: The contact matrix is a square matrix consisting of rows/columns equal to the number age groups. Each element represents the frequency of contacts between age groups. If we believe that transmission of an infection is driven by contact, and that contact rates are very different for different age groups, then specifying a contact matrix allows us to account for age specific rates of transmission. 

[C++]{#cplusplus}
: C++ is a high-level programming language that can be used within R to speed up sections of code. To learn more about C++ check out these [tutorials](https://cplusplus.com/doc/tutorial/) and learn more about the integration of C++ and R [here](https://www.rcpp.org/).

## D

[Deterministic model]{#deterministic}
: Models that will always have the same trajectory for given initial conditions and parameter values. Examples include ordinary differential equations and difference equations. 

[Direct transmission]{#direct}
: Individuals become infected via direct contact with other infected humans. Airborne transmitted infections are often modelled as directly transmitted infections as they require close contact with infected individuals for successful transmission. 

<!-- ## E -->

<!-- ## F -->

<!-- ## G -->

<!-- ## H -->

## I 

[Incubation period]{#incubation}
: The time between becoming infected and the onset of symptoms. [More information on the incubation period](https://en.wikipedia.org/wiki/Latent_period_(epidemiology)#Incubation_period).

[Indirect transmission]{#indirect}
: Indirectly transmitted infections are passed on to humans via contact with vectors, animals or contaminated environment. Vector-borne infections, zoonoses and water-borne infections are modelled as indirectly transmitted. 

[Initial conditions]{#initial}
: In [ODEs](#ordinary), the initial conditions are the values of the state variables at the start of the model simulation (at time 0). For example, if there is one infectious individual in a population of 1000 in an Susceptible-Infectious-Recovered model, the initial conditions would be $S(0) = 999$, $I(0) = 1$, $R(0) = 0$.  


<!-- ## J -->

<!-- ## K -->

## L

[Latent period]{#latent}
: The time between becoming infected and the onset of infectiousness. [More information on the latent period](https://en.wikipedia.org/wiki/Latent_period_(epidemiology)).


## M
[Model parameters (ODEs)]{#parsode}
: The model parameters are used in [ordinary differential equation](#ordinary) models to describe the flow between disease states. For example, a transmission rate $\beta$ is a model parameter that can be used to describe the flow between susceptible and infectious states. 


## N
[Non-pharmaceutical interventions]{#NPIs}
: Non-pharmaceutical interventions (NPIs) are measures put in place to reduce transmission that do not include the administration of drugs or vaccinations. [More information on NPIs](https://www.gov.uk/government/publications/technical-report-on-the-covid-19-pandemic-in-the-uk/chapter-8-non-pharmaceutical-interventions).

## O
[Ordinary differential equations]{#ordinary}
: Ordinary differential equations (ODEs) can be used to represent the rate of change of one variable (e.g. number of infected individuals) with respect to another (e.g. time). Check out this introduction to [ODEs](https://mathinsight.org/ordinary_differential_equation_introduction). ODEs are widely used in infectious disease modelling to model the flow of individuals between different disease states. 

<!-- ## P -->

<!-- ## Q -->

<!-- ## R -->

## S

[State variables]{#state}
: The state variables in a model represented by [ordinary differential equations](#ordinary) are the disease states that individuals can be in e.g. if individuals can be susceptible, infectious or recovered the state variables are $S$, $I$ and $R$. There is an ordinary differential equation for each state variable. 

[Stochastic model]{#stochastic}
: A model that includes some stochastic process resulting in variation in model simulations for the same initial conditions and parameter values. Examples include stochastic differential equations and branching process models. For more detail see [Allen (2017)](https://doi.org/10.1016/j.idm.2017.03.001).


<!-- ## T -->

<!-- ## U -->

## V

[Vector-borne transmission]{#vectorborne}
: Vector-borne transmission means an infection can be passed from a vector (e.g. mosquitoes) to humans. Examples of vector-borne diseases include malaria and dengue. The World Health Organization have a [Fact sheet about Vector-borne diseases](https://www.who.int/news-room/fact-sheets/detail/vector-borne-diseases) with key information and a list of them according to their vector.



<!-- ## W -->

<!-- ## X -->

<!-- ## Y -->

<!-- ## Z -->
