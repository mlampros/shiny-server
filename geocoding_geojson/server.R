
library(shiny); library(leaflet); library(geojsonR)


function(input, output) {

  output$map <- leaflet::renderLeaflet({

    pnt_obj = geojsonR::FROM_GeoJson(input$location, flatten_coords = T, average_coordinates = T)

    average_coords = pnt_obj$leaflet_view_coords                        # save the geometry-average-coordinates for leaflet

    pnt_obj["leaflet_view_coords"] = NULL

    geometry_dump = pnt_obj$geometry_dump                               # save the geometry-dump

    pnt_obj["geometry_dump"] = NULL

    if (pnt_obj$type == "Point") {

      # content = paste(pnt_obj$location,                                  # it works also with "as.vector(unlist(pnt_obj$properties))" however the names are unsorted
      #
      #                 pnt_obj$properties$details,
      #
      #                 sep = "<br/>")

      content = paste(c(paste("<strong>", "GeoJson object :", "</strong>"), "Point"), collapse = " ")

      if (input$map_provider == "OpenStreetMap") {

        tmp <- leaflet::leaflet()

        tmp <- leaflet::addTiles(tmp)

        tmp <- leaflet::addPopups(tmp, lng = pnt_obj$coordinates[1], lat = pnt_obj$coordinates[2],                                                                     # case 1 : geojson geometry 'Point'

                                  content, options = leaflet::popupOptions(closeButton = T))}
      else {

        GLOB_MAP_PROV = paste0("leaflet::providers$", input$map_provider)

        tmp <- leaflet::leaflet()

        tmp <- leaflet::addProviderTiles(tmp, eval(parse(text = GLOB_MAP_PROV)) )

        tmp <- leaflet::addPopups(tmp, lng = pnt_obj$coordinates[1], lat = pnt_obj$coordinates[2],

                                  content, options = leaflet::popupOptions(closeButton = T))
      }
    }

    else if (pnt_obj$type == "Feature" && pnt_obj$geometry$type == "Point") {

      content = paste(c(paste("<strong>", "GeoJson object :", "</strong>"), "Feature", "<br>", paste("<strong>", "Geometry :", "</strong>"), "Point"), collapse = " ")

      if (input$map_provider == "OpenStreetMap") {

        tmp <- leaflet::leaflet()

        tmp <- leaflet::addTiles(tmp)

        tmp <- leaflet::addPopups(tmp, lng = pnt_obj$geometry$coordinates[1], lat = pnt_obj$geometry$coordinates[2],                                                                # case 1 : geojson object 'Feature' of geometry 'Point'

                                  content, options = leaflet::popupOptions(closeButton = T))}

      else {

        GLOB_MAP_PROV = paste0("leaflet::providers$", input$map_provider)

        tmp <- leaflet::leaflet()

        tmp <- leaflet::addProviderTiles(tmp, eval(parse(text = GLOB_MAP_PROV)) )

        tmp <- leaflet::addPopups(tmp, lng = pnt_obj$geometry$coordinates[1], lat = pnt_obj$geometry$coordinates[2],

                                  content, options = leaflet::popupOptions(closeButton = T))
      }
    }

    else {

      if (input$map_provider == "OpenStreetMap") {

        tmp <- leaflet::leaflet()

        tmp <- leaflet::setView(tmp, lng = average_coords[1], lat = average_coords[2], zoom = 4)

        tmp <- leaflet::addTiles(tmp)

        tmp <- leaflet::addGeoJSON(tmp, geometry_dump)}                          # case 2 : the rest of the geojson-geometry-objects

      else {

        GLOB_MAP_PROV = paste0("leaflet::providers$", input$map_provider)

        tmp <- leaflet::leaflet()

        tmp <- leaflet::setView(tmp, lng = average_coords[1], lat = average_coords[2], zoom = 4)

        tmp <- leaflet::addProviderTiles(tmp, eval(parse(text = GLOB_MAP_PROV)) )

        tmp <- leaflet::addGeoJSON(tmp, geometry_dump)
      }
    }
  })
}

