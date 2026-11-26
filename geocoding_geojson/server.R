
library(shiny); library(leaflet); library(geojsonR)

# LOGIN (disabled): on Shinylive / GitHub Pages the app runs in the browser, so a login
# cannot protect anything. Uncomment these lines to use it again on a Shiny server.
# library(shinymanager)
# library(scrypt)

# credentials <- data.frame(user = c("user"),
#                           password = c(scrypt::hashPassword("user")),
#                           is_hashed_password = TRUE,
#                           stringsAsFactors = FALSE)

# Download a URL as text. Works both in regular R and in the browser (webR / Shinylive),
# where base R's download.file() is routed through the browser (the server must allow CORS).
fetch_url_text <- function(u) {
  tmp <- tempfile(fileext = ".json")
  on.exit(unlink(tmp), add = TRUE)
  utils::download.file(u, tmp, quiet = TRUE, mode = "wb")
  paste(readLines(tmp, warn = FALSE, encoding = "UTF-8"), collapse = "")
}


shiny::shinyServer(function(input, output) {

  # # LOGIN (disabled): on Shinylive / GitHub Pages the app runs in the browser, so a login
  # cannot protect anything. Uncomment these lines to use it again on a Shiny server.
  # res_auth <- shinymanager::secure_server(
  #   check_credentials = shinymanager::check_credentials(credentials))

  output$map <- leaflet::renderLeaflet({

    geojson_input = trimws(input$location)
    if (substring(geojson_input, 1, 4) == "http") {                     # download urls here, so that it also works in the browser (Shinylive / webR)
      geojson_input = fetch_url_text(geojson_input)
    }

    pnt_obj = geojsonR::FROM_GeoJson(geojson_input, Flatten_Coords = T, Average_Coordinates = T)

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
})

