# Server
shiny::shinyServer(function(input, output, session) {

  # # LOGIN (disabled): on Shinylive / GitHub Pages the app runs in the browser, so a login
  # cannot protect anything. Uncomment these lines to use it again on a Shiny server.
  # res_auth <- shinymanager::secure_server(
  #   check_credentials = shinymanager::check_credentials(credentials))

  # Reactive values to store coordinates
  coords <- reactiveValues(
    lon = NULL,
    lat = NULL
  )
  
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
        lng <- as.numeric(selected_row$lon)
        lat <- as.numeric(selected_row$lat)
        
        # Update reactive values
        coords$lon <- lng
        coords$lat <- lat
        
        output$map <- leaflet::renderLeaflet({
          info_popup <- paste(
            "<strong>ADDRESS:</strong>", input$results_subset, "<br>",
            "<strong>LONGITUDE:</strong>", lng, "<br>",
            "<strong>LATITUDE:</strong>", lat
          )
          
          map <- leaflet::leaflet() |>
            leaflet::setView(lng = lng, lat = lat, zoom = 15)
          
          if (input$map_provider == "OpenStreetMap") {
            map <- map |> leaflet::addTiles()
          } else {
            tryCatch({
              provider <- eval(parse(text = paste0("leaflet::providers$", input$map_provider)))
              map <- map |> leaflet::addProviderTiles(provider)
            }, error = function(e) {
              map <- map |> leaflet::addTiles()
            })
          }
          
          # Add draggable marker instead of popup
          map |> leaflet::addMarkers(
            lng = lng, 
            lat = lat,
            layerId = "main_marker",
            options = leaflet::markerOptions(draggable = TRUE),
            popup = info_popup
          )
        })
      }
    } else {
      # Clear map if no valid selection
      output$map <- leaflet::renderLeaflet({
        leaflet::leaflet() |> leaflet::addTiles()
      })
      coords$lon <- NULL
      coords$lat <- NULL
    }
  })
  
  # Update coordinates when marker is dragged
  observeEvent(input$map_marker_dragend, {
    coords$lon <- input$map_marker_dragend$lng
    coords$lat <- input$map_marker_dragend$lat
  })
  
  # Output box for coordinates
  output$coordinates_display <- renderUI({
    if (!is.null(coords$lon) && !is.null(coords$lat)) {
      tagList(
        tags$div(
          style = "padding: 15px; background-color: #f8f9fa; border: 1px solid #dee2e6; border-radius: 5px;",
          tags$p(
            style = "margin: 5px 0; font-family: monospace; font-size: 14px;",
            tags$strong("Longitude: "), sprintf("%.4f", coords$lon)
          ),
          tags$p(
            style = "margin: 5px 0; font-family: monospace; font-size: 14px;",
            tags$strong("Latitude: "), sprintf("%.4f", coords$lat)
          )
        )
      )
    } else {
      tags$div(
        style = "padding: 15px; background-color: #f8f9fa; border: 1px solid #dee2e6; border-radius: 5px; color: #6c757d;",
        tags$p("No location selected")
      )
    }
  })
})