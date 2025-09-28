# Server
server <- function(input, output, session) {
  
  # Authentication
  res_auth <- shinymanager::secure_server(
    check_credentials = shinymanager::check_credentials(credentials)
  )
  
  # Reactive value to store geocoding results
  geocode_results <- reactiveVal(NULL)
  
  # Perform reverse geocoding when button is clicked
  observeEvent(input$geocode_btn, {
    
    withProgress(message = 'Reverse geocoding...', value = 0, {
      incProgress(0.3, detail = "Validating coordinates...")
      
      # Validate inputs
      if (is.na(input$latitude) || is.na(input$longitude)) {
        showNotification("Please enter valid numeric coordinates", type = "error")
        return()
      }
      
      if (input$latitude < -90 || input$latitude > 90) {
        showNotification("Latitude must be between -90 and 90", type = "error")
        return()
      }
      
      if (input$longitude < -180 || input$longitude > 180) {
        showNotification("Longitude must be between -180 and 180", type = "error")
        return()
      }
      
      incProgress(0.4, detail = "Making API request...")
      
      # Perform reverse geocoding
      result <- reverse_geocoding_nominatim(
        latitude = input$latitude,
        longitude = input$longitude,
        zoom = input$zoom %||% 10
      )
      
      incProgress(0.3, detail = "Processing results...")
      
      if (nrow(result) > 0 && !is.na(result$address) && result$address != "") {
        geocode_results(result)
        showNotification("Reverse geocoding successful!", type = "message")
      } else {
        geocode_results(NULL)
        showNotification("No address found for these coordinates", type = "warning")
      }
    })
  })
  
  # Display address text
  output$address_text <- renderText({
    result <- geocode_results()
    if (!is.null(result) && nrow(result) > 0) {
      result$address
    } else {
      "No address found. Click 'Reverse Geocode' to search."
    }
  })
  
  # Render map
  output$map <- leaflet::renderLeaflet({
    
    # Initialize map with input coordinates
    map <- leaflet::leaflet() %>%
      leaflet::setView(lng = input$longitude %||% 0, 
                       lat = input$latitude %||% 0, 
                       zoom = 10)
    
    # Add appropriate tile layer
    if (input$map_provider == "OpenStreetMap") {
      map <- map %>% leaflet::addTiles()
    } else {
      tryCatch({
        provider <- eval(parse(text = paste0("leaflet::providers$", input$map_provider)))
        map <- map %>% leaflet::addProviderTiles(provider)
      }, error = function(e) {
        map <- map %>% leaflet::addTiles()  # Fallback to OSM
        showNotification("Map provider not found, using OpenStreetMap", type = "warning")
      })
    }
    
    # Add marker and popup if geocoding was successful
    result <- geocode_results()
    if (!is.null(result) && nrow(result) > 0) {
      
      popup_info <- paste(
        "<strong>Address:</strong><br>", result$address, "<br><br>",
        "<strong>Coordinates:</strong><br>",
        "Lat: ", round(result$lat, 6), "<br>",
        "Lng: ", round(result$lon, 6)
      )
      
      map <- map %>%
        leaflet::setView(lng = result$lon, lat = result$lat, zoom = input$zoom %||% 10) %>%
        leaflet::addMarkers(
          lng = result$lon, 
          lat = result$lat,
          popup = popup_info,
          options = leaflet::popupOptions(closeButton = TRUE)
        )
    } else {
      # Add a marker at input coordinates if no geocoding result
      map <- map %>%
        leaflet::addMarkers(
          lng = input$longitude %||% 0, 
          lat = input$latitude %||% 0,
          popup = paste("Coordinates:", input$latitude %||% 0, ",", input$longitude %||% 0)
        )
    }
    
    return(map)
  })
}