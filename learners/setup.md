---
title: Mise en place
---

## Motivation

**Des épidémies** de maladies infectieuses peuvent apparaître à cause de
différents agents pathogènes et dans différents contextes. Cependant, elles
aboutissent généralement à des questions de santé publique similaires, allant
de la compréhension des dynamiques de transmission et de la gravité clinique à
l'examen de l'effet des mesures de contrôle ([Cori et al. 2017](https://royalsocietypublishing.org/doi/10.1098/rstb.2016.0371#d1e605)).
Nous pouvons relier chacune de ces questions de santé publique à une série de
tâches d'analyse des données épidémidémiologiques. L'efficacité et la
fiabilité de ces tâches peuvent améliorer la rapidité et la précision de la
réponse aux questions sous-jacentes.

Epiverse-TRACE vise à fournir un écosystème logiciel pour
**l'analyse des épidémies**, avec des logiciels communautaires intégrés,
généralisables et évolutifs. Nous:

* soutenons le développement de nouveaux packages R,
* facilitons l'interconnexion des outils existants pour les rendre plus
conviviaux et
* contribuons à une communauté de pratique regroupant épidémiologistes de
terrain, data scientists, chercheurs en laboratoire, analystes d'agences de
santé, ingénieurs logiciels, etc.

### Tutoriels Epiverse-TRACE

Nos tutoriels s'articulent autour d'un pipeline d'analyse de données
épidémiologiques divisé en trois étapes: tâches initiales (au début de
l'épidémie), tâches intermédiaires (quelques semaine après le début de
l'épidémie) et tâches tardives (en pleine épidémie). Les résultats des tâches
réalisées au début de l'épidémie servent généralement de données d'entrée pour
les tâches requises au cours des étapes suivantes.

![Aperçu des thèmes abordés dans le cadre de ce tutoriel](https://epiverse-trace.github.io/task_pipeline-minimal.svg)

Nous avons conçu un site Web pour chaque tâche de ce tutoriel. Chaque site Web
est composé d'un ensemble d'épisodes couvrant différents sujets.

| [Tutoriels pour les premières tâches ➠](https://epiverse-trace.github.io/tutorials-early/)                                                                                                                                | [Didacticiels pour les tâches intermédiaires ➠](https://epiverse-trace.github.io/tutorials-middle)                                                                                                                                          | [Travaux dirigés tardifs ➠](https://epiverse-trace.github.io/tutorials-late/)                                                                   | 
| ------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| Lire et nettoyer les données épidémiologiques, et concevoir un object de la classe {linelist}                                                    | Analyse et prévision en temps réel                                                                                                        | Modélisation de scénarios                                          | 
| Lire, nettoyer et valider les données épidémiologiques, convertir un linelist en incidence pour la visualisation. | Accéder aux distributions des délais épidémiologiques et estimer les paramètres de transmission, prédire le nombre de cas, estimer la gravité clinique et la super-propagation. | Simulez la propagation de la maladie et étudiez les interventions. | 

Chaque épisode contient les sections suivantes:

- **Vue d'ensemble:** décrit les questions auxquelles nous allons répondre
et les objectifs de l'épisode.
- **Conditions préalables:** décrit les épisodes qui doivent idéalement être
complétés au préalable. Elle décrit aussi les librairies qui vont être utilisées
au cours de l'épisode.
- **Exemple de code R:** des exemples de code R afin que vous puissiez
reproduire les analyses sur votre propre ordinateur.
- **Défis:** des défis à relever pour tester votre compréhension.
- **Explicatifs:** des boîtes qui vous permettent de mieux comprendre les
concepts mathématiques et de modélisation.

Consultez également le site [glossaire](./reference.md) pour connaître les
termes qui ne vous sont pas familiers.

### Les Packages R de Epiverse-TRACE

Notre stratégie consiste à intégrer progressivement des **packages R**
spécialisés à un pipeline traditionnel d'analyse de données. Ces librairies
devraient combler les lacunes notées dans ces pipelines d'analyse
épidémiologiques qui sont conçus en vue d'apporter des réponses aux épidémies.

![L'unité fondamentale de partage de code dans **R** est le **package**. Un package regroupe du code, des données, de la documentation et des tests et est facile à partager avec d'autres ([Wickham et Bryan, 2023](https://r-pkgs.org/introduction.html))](episodes/fig/pkgs-hexlogos-2.png)

:::::::::::::::::::::::::::: prereq

Ce contenu suppose une connaissance intermédiaire de R. Ces épisodes sont pour
vous si :

- Vous savez lire des données dans R, les transformer et les reformater, et créer une variété de graphiques.
- Vous connaissez les fonctions de `{dplyr}`, `{tidyr}` et `{ggplot2}`
- Vous pouvez utiliser les opérateurs pipe de `{magrittr}` (`%>%`) et/ou celui
de la librairie de base de R (`|>`).

Nous supposons que les apprenants se sont familiarisés avec les concepts de base
de la statistique, des mathématiques et de la théorie des épidémies, mais NE
DISPOSENT PAS FORCÉMENT de connaissances intermédiaires ou expertes en
modélisation mathématique des maladies infectieuses.

::::::::::::::::::::::::::::

## Configuration des logiciels

Suivez ces deux étapes :

### 1. Installez ou mettez à jour R et RStudio

R et RStudio sont deux logiciels distincts :

- **R** est un langage de programmation et un logiciel utilisé pour exécuter du
code écrit en R.
- **RStudio** est un environnement de développement intégré (IDE) qui facilite
l'utilisation de R. Nous vous recommandons d'utiliser RStudio pour interagir
avec R.

Pour installer R et RStudio, suivez les instructions suivantes
<https://posit.co/download/rstudio-desktop/>.

::::::::::::::::::::::::::::: callout

### Déjà installé ?

Ne perdez pas de temps : C'est le moment idéal pour vous assurer que votre
version de R est à jour.

Ce tutoriel nécessite **la version 4.0.0 de R ou des versions plus récentes**.

:::::::::::::::::::::::::::::

Pour vérifier si votre version de R est à jour :

- Dans RStudio, votre version de R sera imprimée dans
[la fenêtre de la console](https://docs.posit.co/ide/user/ide/guide/code/console.html).
Vous pouvez également exécuter `sessionInfo()`.

- **Pour mettre à jour R** téléchargez et installez la dernière version à partir
du [site web du projet R](https://cran.rstudio.com/) pour votre système
d'exploitation.

  - Après l'installation d'une nouvelle version, vous devrez réinstaller tous vos librairies avec la nouvelle version.
  
  - Pour Windows, la librairie `{installr}` permet de mettre à jour votre version de R et migrer votre bibliothèque de librairies.

- **Pour mettre à jour RStudio** ouvrez RStudio et cliquez sur
`Help > Check for Updates`. Si une nouvelle version est disponible, suivez les
instructions qui s'affichent à l'écran.

::::::::::::::::::::::::::::: callout

### Vérifiez régulièrement les mises à jour

Bien que cela puisse paraître effrayant, il est **plus courant** de
rencontrer des problèmes à cause de l'utilisation de versions obsolètes de R ou
de librairies R. Il est donc recommandé de mettre à jour les versions de R, de
RStudio et de tous les packages que vous utilisez régulièrement.

:::::::::::::::::::::::::::::

### 2. Vérifier et installer les outils de compilation

Certains paquets nécessitent un ensemble d'outils complémentaires pour être compilés.
Ouvrez RStudio et **copiez-collez** le bloc de code suivant dans la 
[fenêtre de console](https://docs.posit.co/ide/user/ide/guide/code/console.html),
puis appuyez sur <kbd>Enter</kbd> (Windows et Linux) ou <kbd>Return</kbd> (MacOS) pour exécuter la commande :

```r
if(!require("pkgbuild")) install.packages("pkgbuild")
pkgbuild::check_build_tools(debug = TRUE)
```

Nous attendons un message similaire à celui ci-dessous :

```output
Your system is ready to build packages!
```

Si les outils de compilation ne sont pas disponibles, cela déclenchera une installation automatique.

1. Exécutez la commande dans la console.
2. Ne l'interrompez pas, attendez que R affiche le message de confirmation.
3. Une fois cela fait, redémarrez votre session R (ou redémarrez simplement RStudio) pour vous assurer que les modifications prennent effet.

Si l'installation automatique **ne fonctionne pas**, vous pouvez les installer manuellement en fonction de votre système d'exploitation.

::::::::::::::::::::::::::::: tab

### Windows

Les utilisateurs Windows auront besoin d'une installation fonctionnelle de `Rtools` afin de compiler le paquet à partir du code source.  
`Rtools` n'est pas un paquet R, mais un logiciel que vous devez télécharger et installer.
Nous vous suggérons de suivre les étapes suivantes :

- **Installez `Rtools`**. Téléchargez le programme d'installation de `Rtools` à partir de <https://cran.r-project.org/bin/windows/Rtools/>. Installez-le en conservant les sélections par défaut.
- Fermez et rouvrez RStudio afin qu'il puisse reconnaître la nouvelle installation.

### Mac

Les utilisateurs Mac doivent suivre deux étapes supplémentaires, comme indiqué dans ce [guide de configuration de la chaîne d'outils C pour Mac](https://github.com/stan-dev/rstan/wiki/Configuring-C---Toolchain-for-Mac) :

- Installez et utilisez [`macrtools`](https://mac.thecoatlessprofessor.com/macrtools/) pour configurer la chaîne d'outils C++
- Activez certaines optimisations du compilateur.

### Linux

Les utilisateurs Linux doivent suivre des instructions spécifiques à leur distribution. Vous les trouverez dans ce [guide de configuration de la chaîne d'outils C pour Linux](https://github.com/stan-dev/rstan/wiki/Configuring-C-Toolchain-for-Linux).

:::::::::::::::::::::::::::::

::::::::::::: callout

### Vérification de l'environnement

Cette étape nécessite des privilèges d'administrateur pour installer le logiciel.

Si vous ne disposez pas des droits d'administrateur dans votre environnement actuel :  

- Essayez d'exécuter le tutoriel sur votre **ordinateur personnel** auquel vous avez un accès complet.  
- Utilisez un **environnement de développement préconfiguré** (par exemple, [Posit Cloud](https://posit.cloud/)).  
- Demandez à votre **administrateur système** d'installer les logiciels requis pour vous.  

:::::::::::::

### 3. Installez les librairies R requises

Ouvrez RStudio et **copiez et collez** le morceau de code suivant dans la
[fenêtre de la console](https://docs.posit.co/ide/user/ide/guide/code/console.html)
puis appuyez sur la touche <kbd>Entrer</kbd> (Windows et Linux) ou
<kbd>Retour</kbd> (MacOS) pour exécuter la commande :

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

new_packages <- c(
  "epicontacts",
  "fitdistrplus",
  "superspreading",
  "epichains",
  "epiparameter",
  "incidence2",
  "outbreaks",
  "tidyverse"
)

pak::pkg_install(new_packages)
```

Ces étapes d'installation peuvent vous demander `? Do you want to continue (Y/n)`
écrivez `Y` et d'appuyer sur <kbd>Entrez</kbd>.

::::::::::::::::::::::::::::: spoiler

### obtenez-vous un message d'erreur lors de l'installation de d'autres librairies ?

Vous pouvez utiliser la function `install.packages()` de la librairie de base de
R.

```r
install.packages("cfr")
```

:::::::::::::::::::::::::::::

::::::::::::::::::::::::::: spoiler

### Que faire si une erreur persiste ?

Si le mot-clé du message d'erreur contient ceci: `Personal access token (PAT)`,
vous devrez peut-être [configurer votre token GitHub](https://epiverse-trace.github.io/git-rstudio-basics/02-setup.html#set-up-your-github-token).

Installez d'abord ces librairies :

```r
if(!require("pak")) install.packages("pak")

new <- c("gh",
         "gitcreds",
         "usethis")

pak::pak(new)
```

Ensuite, suivez ces trois étapes pour [configurer votre token GitHub (lisez ce guide étape par étape)](https://epiverse-trace.github.io/git-rstudio-basics/02-setup.html#set-up-your-github-token):

```r
# creer un token
usethis::create_github_token()

# configurer votre token 
gitcreds::gitcreds_set()

# obtenir un rapport de votre situation
usethis::git_sitrep()
```

Puis Réessayez d'installer {tracetheme} par example:

```r
if(!require("remotes")) install.packages("remotes")
remotes::install_github("epiverse-trace/tracetheme")
```

Si l'erreur persiste, [contactez-nous](#your-questions)!

:::::::::::::::::::::::::::

Vous devez mettre à jour **toutes les librairies** nécessaires à ce tutoriel,
même si vous les avez installés récemment. Les nouvelles versions contiennent
des améliorations et d'importantes corrections de bugs.

### 4. Vérifiez l'installation

Lorsque l'installation est terminée, vous pouvez essayer de charger les packages
en copiant et collant le code suivant dans la console :

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

Si vous ne voyez PAS d'erreur comme `there is no package called '...'` vous êtes
prêt à commencer ! Si c'est le cas, [contactez-nous](#your-questions)!

### 5. Regardez et lisez le matériel de préformation

:::::::::::::::::::::::::: prereq

<!-- de 5 minutes -->
**Regardez** deux vidéos pour rafraîchir vos connaissances sur les distributions statistiques :

- 365 Data Science (2019)
**Probabilité : types de distributions**, YouTube (Sous-titres en français, 7 min).
Disponible à l'adresse : <https://www.youtube.com/watch?v=b9a27XN_6tg>

- Samuel Rey-Mermet (2020)
**Statistiques et distributions de probabilités**, YouTube (En français, 30 min)
Disponible à l'adresse : <https://www.youtube.com/watch?v=qnRR466YMew>

<!--
- StatQuest avec Josh Starmer (2017) 
**Les principales idées derrière les distributions de probabilité**, YouTube.
Disponible à l'adresse : <https://www.youtube.com/watch?v=oI3hZJqXJuc&t>

- StatQuest avec Josh Starmer (2018) 
**La probabilité n'est pas la vraisemblance. Découvrez pourquoi !!!**, YouTube.
Disponible à l'adresse : <https://www.youtube.com/watch?v=pYxNSUDSFH4>

- StatQuest avec Josh Starmer (2017) 
**La vraisemblance maximale, expliquée clairement !!!**, YouTube. 
Disponible à l'adresse : <https://www.youtube.com/watch?v=XepXtl9YKwc>
-->

::::::::::::::::::::::::::

## Les jeux de données

### Téléchargez les données

Nous téléchargerons les données directement à partir de R au cours du tutoriel.
Cependant, si vous vous attendez à des problèmes de réseau, il peut être
préférable de télécharger les données à l'avance et de les stocker sur votre
machine.

Les fichiers contenant les données pour le tutoriel peuvent être téléchargés
manuellement à partir d'ici :

- <https://epiverse-trace.github.io/tutorials-middle/data/ebola_cases.csv>

- <https://epiverse-trace.github.io/tutorials-middle/data/sarscov2_cases_deaths.csv>

## Vos questions

Si vous avez besoin d'aide pour installer les logiciels et les librairies ou si
vous avez d'autres questions concernant ce tutoriel, veuillez envoyer un
courriel à l'adresse suivante
[andree.valle-campos@lshtm.ac.uk](mailto:andree.valle-campos@lshtm.ac.uk)

