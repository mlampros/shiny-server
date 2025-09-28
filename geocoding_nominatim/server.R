# Server
shiny::shinyServer(function(input, output, session) {
  
  res_auth <- shinymanager::secure_server(
    check_credentials = shinymanager::check_credentials(credentials))  
  
  # Only trigger search when button is clicked
  search_results <- eventReactive(input$search_btn, {
    
    # Show progress
    withProgress(message = 'Searching location...', value = 0, {
      incProgress(0.5)
      
      result <- address_geocoding_nominatim(
        streetname = input$streetname, 
        housenumber = input$housenumber, 
        city = input$city, 
        county = input$county, 
        state = input$state, 
        country = input$country, 
        postalcode = input$postalcode
      )
      
      incProgress(0.5)
      return(result)
    })
  })
  
  # Update select input when search results change
  observeEvent(search_results(), {
    outVar <- search_results()
    
    if (nrow(outVar) == 0 || length(outVar$display_name) == 0) {
      updateSelectInput(session, "results_subset", choices = "No results found")
    } else {
      updateSelectInput(session, "results_subset", choices = outVar$display_name)
    }
  })
  
  # Render map when location is selected
  observeEvent(input$results_subset, {
    outVar <- search_results()
    
    if (input$results_subset != "No location searched" && 
        input$results_subset != "No results found" && 
        nrow(outVar) > 0) {
      
      selected_row <- outVar[outVar$display_name == input$results_subset, ]
      
      if (nrow(selected_row) > 0) {
        output$map <- leaflet::renderLeaflet({
          
          lng <- as.numeric(selected_row$lon)
          lat <- as.numeric(selected_row$lat)
          
          info_popup <- paste(
            "<strong>ADDRESS:</strong>", input$results_subset, "<br>",
            "<strong>LONGITUDE:</strong>", lng, "<br>",
            "<strong>LATITUDE:</strong>", lat
          )
          
          map <- leaflet::leaflet() %>%
            leaflet::setView(lng = lng, lat = lat, zoom = 15)
          
          if (input$map_provider == "OpenStreetMap") {
            map <- map %>% leaflet::addTiles()
          } else {
            tryCatch({
              provider <- eval(parse(text = paste0("leaflet::providers$", input$map_provider)))
              map <- map %>% leaflet::addProviderTiles(provider)
            }, error = function(e) {
              map <- map %>% leaflet::addTiles()  # Fallback to OSM
            })
          }
          
          map %>% leaflet::addPopups(
            lng = lng, lat = lat, popup = info_popup,
            options = leaflet::popupOptions(closeButton = TRUE)
          )
        })
      }
    } else {
      # Clear map if no valid selection
      output$map <- leaflet::renderLeaflet({
        leaflet::leaflet() %>% leaflet::addTiles()
      })
    }
  })
})