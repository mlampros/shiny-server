<br>

<a href="https://www.buymeacoffee.com/VY0x8snyh" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" height="21px" ></a>

<br>


### **geocoding shiny applications**

<br>

To open the applications *from inside an R session* use,

* shiny::runGitHub('shiny-server', 'mlampros', subdir = 'geocoding_geojson')
* shiny::runGitHub('shiny-server', 'mlampros', subdir = 'geocoding_nominatim')
* shiny::runGitHub('shiny-server', 'mlampros', subdir = 'geocoding_nominatim_reverse')

or follow the web-links using the [shinyapps.io](http://www.shinyapps.io/) service,

* https://lampros.shinyapps.io/shiny_geocoding/
* https://lampros.shinyapps.io/shiny_geojson/
* https://lampros.shinyapps.io/shiny_reverse_geocoding/
* https://lampros.shinyapps.io/string_matching/  [ string matching based on a [fuzzywuzzyR issue](https://github.com/mlampros/fuzzywuzzyR/issues/4) ]

To deploy a shiny application using *shinyapps.io* first use as working directory the shiny application folder and then run:

```R
library(rsconnect)
deployApp()

```

To install an older version of the *rsconnect* package based on a github-commit use:

```R
devtools::install_github("rstudio/rsconnect", ref='737cd484a501da5589fe49ca3ee43a4b225366af')

```

The *shinyapps.io* service is limited to 25 active hours per month (for free accounts), thus if the limit is exceeded then the applications won't be available to the end users.


More details / options on how to build / share shiny applications can be found in the following links:


https://shiny.rstudio.com/tutorial/written-tutorial/lesson7/ <br>
http://deanattali.com/2015/05/09/setup-rstudio-shiny-server-digital-ocean/

[An issue related with reticulate-python-shiny application](https://community.rstudio.com/t/problem-deploying-app-using-a-virtual-env-with-reticulate-to-run-python-code-in-app-error-virtual-environment-permission-denied/25283/15)
