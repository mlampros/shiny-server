
library(shiny); library(leaflet)

# LOGIN (disabled): on Shinylive / GitHub Pages the app runs in the browser, so a login
# cannot protect anything. Uncomment these lines to use it again on a Shiny server.
# shinymanager::secure_app(       # opening of the login wrapper
fluidPage(

  titlePanel("Geocoding using a geojson file/script, Shiny and Leaflet"),

  textInput(inputId = "location", label = "Data Input", value = 'https://raw.githubusercontent.com/mlampros/DataSets/master/california.geojson', width = '100%'),       # '{ "type": "Point", "coordinates": [-120.248484, 33.999329] }'

  textInput(inputId = "map_provider", label = "map_provider", value = "OpenStreetMap", width = '40%'),                                       # test map_provider using : 'CartoDB.Positron'

  leaflet::leafletOutput(outputId = "map", width = "100%", height = 900)
)
# )                              # closing of the login wrapper
