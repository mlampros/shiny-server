# UI
ui <- shinymanager::secure_app(
  fluidPage(
    titlePanel("Reverse Geocoding using Shiny, Nominatim OSM and Leaflet"),
    
    fluidRow(
      column(3, 
             numericInput("latitude", "Latitude (-90 to 90):", 
                          value = 39.436231365017846, min = -90, max = 90, step = 0.000001)
      ),
      column(3, 
             numericInput("longitude", "Longitude (-180 to 180):", 
                          value = 20.512798469567628, min = -180, max = 180, step = 0.000001)
      ),
      column(2, 
             numericInput("zoom", "Zoom Level (0-18):", 
                          value = 10, min = 0, max = 18, step = 1)
      ),
      column(2, 
             selectInput("map_provider", "Map Provider:", 
                         choices = c("OpenStreetMap", "CartoDB.Positron", 
                                     "CartoDB.DarkMatter", "Esri.WorldImagery"),
                         selected = "OpenStreetMap")
      ),
      column(2, 
             br(),
             actionButton("geocode_btn", "Reverse Geocode", 
                          class = "btn-primary", style = "margin-top: 5px;")
      )
    ),
    
    br(),
    
    fluidRow(
      column(12,
             div(id = "address_output", style = "margin-bottom: 15px;",
                 h4("Address:", style = "margin: 0;"),
                 verbatimTextOutput("address_text")
             )
      )
    ),
    
    leaflet::leafletOutput("map", width = "100%", height = 600),
    
    br(),
    
    fluidRow(
      column(12,
             h5("Instructions:"),
             p("1. Enter valid latitude and longitude coordinates"),
             p("2. Optionally adjust the zoom level (higher = more detailed address)"),
             p("3. Click 'Reverse Geocode' to find the address"),
             p("4. Click on the map marker to see the full address")
      )
    )
  )
)
