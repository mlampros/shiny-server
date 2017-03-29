
library(shiny); library(leaflet)

# ui.R


fluidPage(

  titlePanel("Reverse Geocoding using Shiny, Nominatim OSM and Leaflet"),

  textInput(inputId = "latitude", label = "latitude", value = NULL, width = '30%'),
  textInput(inputId = "longitude", label = "longitude", value = NULL, width = '30%'),
  textInput(inputId = "zoom", label = "zoom", value = NULL, width = '10%'),
  textInput(inputId = "map_provider", label = "map_provider", value = "OpenStreetMap", width = '40%'),           # test map_provider using : 'CartoDB.Positron'

  leaflet::leafletOutput(outputId = "map", width = "100%", height = 900)
)
