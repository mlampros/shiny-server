
library(shiny); library(leaflet)


fluidPage(

  titlePanel("Geocoding using a geojson file/script, Shiny and Leaflet"),

  textInput(inputId = "location", label = "Data Input", value = '/home/lampros/Downloads/GEOJSON/california.geojson', width = '100%'),       # '{ "type": "Point", "coordinates": [-120.248484, 33.999329] }'

  textInput(inputId = "map_provider", label = "map_provider", value = "OpenStreetMap", width = '40%'),                                       # test map_provider using : 'CartoDB.Positron'

  leaflet::leafletOutput(outputId = "map", width = "100%", height = 900)
)
