
<br>

### **shiny applications**

<br>

To open the applications *from inside an R session* use,

```R

setwd('shiny-server')

shiny::runGitHub('shiny-server', 'mlampros', subdir = 'geocoding_geojson')
shiny::runGitHub('shiny-server', 'mlampros', subdir = 'geocoding_nominatim')
shiny::runGitHub('shiny-server', 'mlampros', subdir = 'geocoding_nominatim_reverse')
shiny::runGitHub('shiny-server', 'mlampros', subdir = 'string_matching')

```

<br>

**or** download the repository then make one of the applications your working directory and run

```R
library(shiny)
runApp()

```

<br>

### **Online (Shinylive on GitHub Pages)**

<br>

The applications also run in the browser, without a server, using [Shinylive](https://posit-dev.github.io/r-shinylive/) (R compiled to WebAssembly via [webR](https://docs.r-wasm.org/webr/latest/)):

* https://mlampros.github.io/shiny-server/  (all applications)
* https://mlampros.github.io/shiny-server/geocoding_nominatim/
* https://mlampros.github.io/shiny-server/geocoding_nominatim_reverse/
* https://mlampros.github.io/shiny-server/geocoding_geojson/
* https://mlampros.github.io/shiny-server/string_matching/  [ string matching based on a [fuzzywuzzyR issue](https://github.com/mlampros/fuzzywuzzyR/issues/4) ]

The site is built and deployed by the GitHub Action *.github/workflows/deploy-shinylive.yml* on every push to the *master* branch. The first visit can take some seconds, because webR and the required R packages are downloaded to the browser.

To build the site locally use,

```R
apps = c("geocoding_nominatim", "geocoding_nominatim_reverse", "geocoding_geojson", "string_matching")
for (app in apps) shinylive::export(appdir = app, destdir = "_site", subdir = app)
httpuv::runStaticServer("_site")

```

<br>

More details / options on how to build / share shiny applications can be found in the following links:

* https://shiny.posit.co/r/getstarted/shiny-basics/lesson7/ <br>
* https://github.com/posit-dev/r-shinylive <br>
* http://deanattali.com/2015/05/09/setup-rstudio-shiny-server-digital-ocean/

<br>
