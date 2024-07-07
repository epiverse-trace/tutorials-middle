---
title: Setup
---

## Motivación

**Los brotes** aparecen con diferentes enfermedades y en diferentes contextos, pero lo que todos ellos tienen en común son las preguntas clave en salud pública ([Cori et al. 2017](https://royalsocietypublishing.org/doi/10.1098/rstb.2016.0371#d1e605)). Podemos relacionar estas preguntas clave en salud pública con las tareas de análisis de datos de brotes.

Epiverse-TRACE tiene como objetivo proporcionar un ecosistema de software para [**análisis de brotes**](reference.md#outbreakanalytics) con software integrado, generalizable y escalable impulsado por la comunidad. Apoyamos el desarrollo de paquetes R, hacemos que los existentes sean interoperables para la experiencia del usuario y estimulamos una comunidad de práctica.

### Tutoriales Epiverse-TRACE

Los tutoriales giran en torno a un proceso de análisis de brotes dividido en tres etapas: **Tareas iniciales**, **Tareas intermedias** y **Tareas finales**.

![Resumen de los temas de los tutoriales](https://epiverse-trace.github.io/task_pipeline-minimal.svg)

Cada tarea tiene su sitio web tutorial. Cada tutorial consta de un conjunto de episodios.

| [Tutoriales de tareas tempranas ➠](https://epiverse-trace.github.io/tutorials-early/) |[Tutoriales de tareas intermedias ➠](https://epiverse-trace.github.io/tutorials-middle) |[Tutoriales de tareas tardías ➠](https://epiverse-trace.github.io/tutorials-late/)
|---|---|---|
| Leer y limpiar datos de casos, convertir en datos de incidencia para su visualización. | Análisis en tiempo real y pronóstico de casos. | Modelamiento de escenarios e investigación de intervenciones. |

Cada episodio contiene:

+ **Hoja de ruta**: describe qué preguntas se responderán y cuáles son los objetivos del episodio.
+ **Requisitos previos**: describe qué episodios/paquetes deben cubrirse antes del episodio actual.
+ **Código R de ejemplo**: trabaje los episodios en su propio ordenador utilizando el código R de ejemplo.
+ **Desafíos**: completa los desafíos para poner a prueba tu comprensión.
+ **Explicadores**: amplía tu comprensión de los conceptos matemáticos y de modelización con los cuadros explicativos.

Consulta también el [glosario](../reference.md) para conocer los términos con los que no estés familiarizado.

### Paquetes de R del Epiverse-TRACE

Nuestra estrategia consiste en incorporar gradualmente **paquetes R** especializados a un proceso de análisis tradicional. Estos paquetes deberían llenar los vacíos en estas tareas específicas de epidemiología en respuesta a los brotes.

![En **R**, la unidad fundamental de código compartible es el **paquete**. Un paquete agrupa código, datos, documentación y pruebas y es fácil de compartir con otros ([Wickham y Bryan, 2023](https://r-pkgs.org/introduction.html))](episodes/fig/pkgs-hexlogos-2.png).

:::::::::::::::::::::::::::: prereq

Este contenido asume un conocimiento intermedio de R. Estos tutoriales son para ti si:

- Puedes leer datos en R, transformar y remodelar datos, y hacer una amplia variedad de gráficos.
- Estás familiarizado con las funciones de `{dplyr}`, `{tidyr}` y `{ggplot2}`.
- Puede utilizar la tubería magrittr `%>%` y/o la tubería nativa `|>`.


Esperamos que los alumnos tengan cierta exposición a conceptos básicos de estadística, matemáticas y teoría epidémica, pero NO familiaridad intermedia o experta con el modelamiento.

::::::::::::::::::::::::::::

## Configuración del software

Siga estos dos pasos:

### 1. Instale o actualice R y RStudio

R y RStudio son dos piezas separadas de software: 

* **R** es un lenguaje de programación y software utilizado para ejecutar código escrito en R.
* **RStudio** es un entorno de desarrollo integrado (IDE) que facilita el uso de R. Recomendamos utilizar RStudio para interactuar con R. 

Para instalar R y RStudio, siga estas instrucciones <https://posit.co/download/rstudio-desktop/>.

::::::::::::::::::::::::::::: callout

### ¿Ya está instalado? 

Espere: Este es un buen momento para asegurarse de que su instalación de R está actualizada.

Este tutorial requiere **R versión 4.0.0 o posterior**.

:::::::::::::::::::::::::::::

Para comprobar si tu versión de R está actualizada:

- En RStudio tu versión de R se imprimirá en [la ventana de la consola](https://docs.posit.co/ide/user/ide/guide/code/console.html). O ejecute `sessionInfo()` allí.

- **Para actualizar R**, descargue e instale la última versión desde el [sitio web del proyecto R](https://cran.rstudio.com/) para su sistema operativo.

  - Después de instalar una nueva versión, tendrás que reinstalar todos tus paquetes con la nueva versión. 

  - Para Windows, el paquete `{installr}` puede actualizar su versión de R y migrar su biblioteca de paquetes.

- **Para actualizar RStudio**, abra RStudio y haga clic en 
Ayuda > Buscar actualizaciones`. Si hay una nueva versión disponible siga las 
instrucciones en pantalla.

::::::::::::::::::::::::::::: callout

### Buscar actualizaciones regularmente

Aunque esto puede sonar aterrador, es **mucho más común** encontrarse con problemas debido al uso de versiones desactualizadas de R o de paquetes de R. Mantenerse al día con las últimas versiones de R, RStudio, y cualquier paquete que utilice regularmente es una buena práctica.

:::::::::::::::::::::::::::::

### 2. Instale los paquetes R necesarios

<!--
During the tutorial, we will need a number of R packages. Packages contain useful R code written by other people. We will use packages from the [Epiverse-TRACE](https://epiverse-trace.github.io/). 
-->

Abra RStudio y **copie y pegue** el siguiente fragmento de código en la [ventana de la consola](https://docs.posit.co/ide/user/ide/guide/code/console.html), luego presione < kbd>Enter</kbd> (Windows y Linux) o <kbd>Return</kbd> (MacOS) para ejecutar el comando:

```r
# para episodios sobre acceso a retrasos temporales y cuantificar la transmisión

if(!require("pak")) install.packages("pak")

new_packages <- c(
  "EpiNow2",
  "epiverse-trace/epiparameter",
  "incidence2",
  "tidyverse"
)

pak::pkg_install(new_packages)
```

```r
# para episodios sobre pronóstico y severidad

if(!require("pak")) install.packages("pak")

new_packages <- c(
  "EpiNow2",
  "cfr",
  "epiverse-trace/epiparameter",
  "incidence2",
  "outbreaks",
  "tidyverse"
)

pak::pkg_install(new_packages)
```

<!--
```r
# para episodios sobre superdispersión y cadenas de transmisión

if(!require("pak")) install.packages("pak")

superspreading_packages <- c(
  "epicontacts",
  "fitdistrplus",
  "epiverse-trace/superspreading",
  "epiverse-trace/epichains",
  "epiverse-trace/epiparameter",
  "incidence2",
  "outbreaks",
  "tidyverse"
)

pak::pkg_install(superspreading_packages)
```
-->

Estos pasos de instalación podrían preguntarle `? Do you want to continue (Y/n)` escriba `Y` y presione <kbd>Enter</kbd>.

::::::::::::::::::::::::::::: spoiler

### ¿obtiene un error con EpiNow2?

Los usuarios de Windows necesitarán una instalación funcional de `Rtools` para construir el paquete desde el código fuente. `Rtools` no es un paquete de R, sino un software que necesita descargar e instalar. Le sugerimos lo siguiente:

1. **Verifique la instalación de `Rtools`. Puedes hacerlo utilizando la búsqueda de Windows en tu sistema. Opcionalmente, puedes utilizar `{devtools}` en ejecución: 

```r
if(!require("devtools")) install.packages("devtools")
devtools::find_rtools()
```

Si el resultado es `FALSE`, entonces debe realizar el paso 2.

2. **Instale `Rtools`**. Descargue el instalador de `Rtools` de <https://cran.r-project.org/bin/windows/Rtools/>. Instale con las selecciones por defecto.

3. **Verificar la instalación de `Rtools`**. De nuevo, podemos usar `{devtools}`:

```r
if(!require("devtools")) install.packages("devtools")
devtools::find_rtools()
```

:::::::::::::::::::::::::::::

::::::::::::::::::::::::::::: spoiler

### ¿obtiene un error con los paquetes epiverse-trace?

Si recibe un mensaje de error al instalar {superspreading}, {epichains}, o {epiparameter}, pruebe este código alternativo:

```r
# for superspreading
install.packages("superspreading", repos = c("https://epiverse-trace.r-universe.dev"))

# for epiparameter
install.packages("epiparameter", repos = c("https://epiverse-trace.r-universe.dev"))

# for epichains
install.packages("epichains", repos = c("https://epiverse-trace.r-universe.dev"))
```

:::::::::::::::::::::::::::::

::::::::::::::::::::::::::: spoiler

### ¿Qué hacer si persiste un Error?

Si la palabra clave del mensaje de error incluye una cadena como `Personal access token (PAT)`, puede que necesites [configurar tu token de GitHub](https://epiverse-trace.github.io/git-rstudio-basics/02-setup.html#set-up-your-github-token).

Primero, instala estos paquetes de R:

```r
if(!require("pak")) install.packages("pak")

new <- c("gh",
         "gitcreds",
         "usethis")

pak::pak(new)
```

A continuación, sigue estos tres pasos para [configurar tu token de GitHub (lee esta guía paso a paso)](https://epiverse-trace.github.io/git-rstudio-basics/02-setup.html#set-up-your-github-token):

```r
# Generate a token
usethis::create_github_token()

# Configure your token 
gitcreds::gitcreds_set()

# Get a situational report
usethis::git_sitrep()
```

Intente de nuevo instalar {epichains}:

```r
if(!require("remotes")) install.packages("remotes")
remotes::install_github("epiverse-trace/epichains")
```

Si el error persiste, [póngase en contacto con nosotros](#your-questions)!

:::::::::::::::::::::::::::

Debería actualizar **todos los paquetes** necesarios para el tutorial, aunque los haya instalado hace relativamente poco. Las nuevas versiones traen mejoras y correcciones de errores importantes.

Cuando la instalación haya terminado, puedes intentar cargar los paquetes pegando el siguiente código en la consola:

```r
# para episodios sobre acceso a retrasos temporales y cuantificar la transmisión

library(EpiNow2)
library(epiparameter)
library(incidence2)
library(tidyverse)
```

```r
# para episodios sobre pronóstico y severidad

library(EpiNow2)
library(cfr)
library(epiparameter)
library(incidence2)
library(outbreaks)
library(tidyverse)
```

<!--
```r
# para episodios sobre superdispersión y cadenas de transmisión

library(epicontacts)
library(fitdistrplus)
library(superspreading)
library(epichains)
library(epiparameter)
library(incidence2)
library(outbreaks)
library(tidyverse)
```
-->

Si NO aparece un error del tipo `no hay ningún paquete llamado '...'`, ¡puede continuar! Si es así, [contacte con nosotros](#your-questions)!

## Conjuntos de datos

### Descargar los datos

Descargaremos los datos directamente desde R durante el tutorial. Sin embargo, si esperas problemas con la red, puede ser mejor descargar los datos de antemano y almacenarlos en tu máquina.

Los archivos de datos para el tutorial se pueden descargar manualmente aquí: 

- <https://epiverse-trace.github.io/tutorials-middle/data/ebola_cases.csv>

- <https://epiverse-trace.github.io/tutorials-middle/data/sarscov2_cases_deaths.csv>

## Sus preguntas

Si necesita ayuda para instalar el software o tiene alguna otra pregunta sobre este tutorial, envíe un correo electrónico a <andree.valle-campos@lshtm.ac.uk>
