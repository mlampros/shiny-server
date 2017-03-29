
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

The latter service is limited to 25 active hours per month for free accounts, thus if the limit is exceeded then the applications won't be available to the end users.


More details / options on how to build / share shiny applications can be found in the following links:


https://shiny.rstudio.com/tutorial/lesson7/ <br>
http://deanattali.com/2015/05/09/setup-rstudio-shiny-server-digital-ocean/#custom-domain
