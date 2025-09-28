# UI
shinymanager::secure_app(fluidPage(
  titlePanel("Geocoding using Shiny, Nominatim OSM and Leaflet"),
  
  fluidRow(
    column(6, textInput("streetname", "Street Name", width = '100%')),
    column(2, textInput("housenumber", "House Number", width = '100%')),
    column(4, textInput("city", "City", width = '100%'))
  ),
  
  fluidRow(
    column(4, textInput("county", "County", width = '100%')),
    column(4, textInput("state", "State", width = '100%')),
    column(4, textInput("country", "Country", width = '100%'))
  ),
  
  fluidRow(
    column(4, textInput("postalcode", "Postal Code", width = '100%')),
    column(4, textInput("map_provider", "Map Provider", value = "OpenStreetMap", width = '100%')),
    column(4, br(), actionButton("search_btn", "Search Location", class = "btn-primary"))
  ),
  
  br(),
  selectInput('results_subset', 'Output Locations', choices = "No location searched", width = '100%'),
  br(),
  leaflet::leafletOutput("map", width = "100%", height = 600)
))