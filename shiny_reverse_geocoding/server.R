
library(shiny); library(leaflet)


# server.R

function(input, output){

    output$map <- leaflet::renderLeaflet({

      QUERY = reverse_geocoding_nominatim(latitude = input$latitude, longitude = input$longitude, zoom = input$zoom)

      if (!is.null(QUERY$address)) {

        INFO = paste(c(paste("<strong>", "ADDRESS :", "</strong>"), QUERY$address), collapse = " ")

        if (input$map_provider == "OpenStreetMap") {

          tmp <- leaflet::leaflet()

          tmp <- leaflet::addTiles(tmp)

          tmp <- leaflet::addPopups(tmp, lng = QUERY$lon, lat = QUERY$lat, INFO, options = leaflet::popupOptions(closeButton = T))}

        else {

          GLOB_MAP_PROV = paste0("leaflet::providers$", input$map_provider)

          tmp <- leaflet::leaflet()

          tmp <- leaflet::addProviderTiles(tmp, eval(parse(text = GLOB_MAP_PROV)) )

          tmp <- leaflet::addPopups(tmp, lng = QUERY$lon, lat = QUERY$lat, INFO, options = leaflet::popupOptions(closeButton = T))
        }
      }
    })
}

