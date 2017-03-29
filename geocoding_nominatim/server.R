
library(shiny); library(leaflet)


# server.R


function(input, output, session){

  outVar = reactive({

    QUERY = address_geocoding_nominatim(streetname = input$streetname, housenumber = input$housenumber, city = input$city,

                                        county = input$county, state = input$state, country = input$country, postalcode = input$postalcode)
  })

  observe({

    if (length(outVar()$display_name) == 0) {

      updateSelectInput(session, "results_subset", choices = "unknown location")}

    else {

      updateSelectInput(session, "results_subset", choices = outVar()$display_name)

      output$map <- leaflet::renderLeaflet({

        INFO = paste(c(paste("<strong>", "ADDRESS :", "</strong>"), input$results_subset, "<br>", paste("<strong>", "LONGITUDE :", "</strong>"),

                       as.numeric(outVar()[which(outVar()$display_name == input$results_subset), 'lon']), "<br>", paste("<strong>", "LATITUDE :", "</strong>"),

                       as.numeric(outVar()[which(outVar()$display_name == input$results_subset), 'lat'])), collapse = " ")

        if (input$map_provider == "OpenStreetMap") {

          tmp <- leaflet::leaflet()

          tmp <- leaflet::addTiles(tmp)

          tmp <- leaflet::addPopups(tmp, lng = as.numeric(outVar()[which(outVar()$display_name == input$results_subset), 'lon']),

                                    lat = as.numeric(outVar()[which(outVar()$display_name == input$results_subset), 'lat']),

                                    INFO, options = leaflet::popupOptions(closeButton = T))}

        else {

          GLOB_MAP_PROV = paste0("leaflet::providers$", input$map_provider)

          tmp <- leaflet::leaflet()

          tmp <- leaflet::addProviderTiles(tmp, eval(parse(text = GLOB_MAP_PROV)) )

          tmp <- leaflet::addPopups(tmp, lng = as.numeric(outVar()[which(outVar()$display_name == input$results_subset), 'lon']),

                                    lat = as.numeric(outVar()[which(outVar()$display_name == input$results_subset), 'lat']),

                                    input$results_subset, options = leaflet::popupOptions(closeButton = T))

          #--------------------------------------------------------------
          # magritrr's pipe %>% causes an error when building the package
          #--------------------------------------------------------------
        }
      })
    }
  })
}
