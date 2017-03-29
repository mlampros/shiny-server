
library(shiny); library(leaflet)

# ui.R


fluidPage(

  titlePanel("Geocoding using Shiny, Nominatim OSM and Leaflet"),

  textInput(inputId = "streetname", label = "streetname", value = NULL, width = '80%'),
  textInput(inputId = "housenumber", label = "housenumber", value = NULL, width = '8%'),
  textInput(inputId = "city", label = "city", value = NULL, width = '50%'),
  textInput(inputId = "county", label = "county", value = NULL, width = '50%'),
  textInput(inputId = "state", label = "state", value = NULL, width = '50%'),
  textInput(inputId = "country", label = "country", value = NULL, width = '50%'),
  textInput(inputId = "postalcode", label = "postalcode", value = NULL, width = '15%'),
  textInput(inputId = "map_provider", label = "map_provider", value = "OpenStreetMap", width = '40%'),              # test map_provider using : 'CartoDB.Positron'

  selectInput('results_subset', 'Output Locations', "unknown location", width = '100%'),

  leaflet::leafletOutput(outputId = "map", width = "100%", height = 900)
)
