
library(shiny); library(geojsonR)


# secondary function for the 'geocoding_nominatim_reverse()' function
#

reverse_geocoding_nominatim = function(latitude = NULL, longitude = NULL, zoom = 0) {

  if (zoom > 18) {

    cat("the 'zoom' parameter should be a numeric value between 0 and 18", "\n")

    zoom = 0                   # assign a value of 0 to the zoom parameter if it's out of range
  }

  tmp_lst = list(latitude = latitude, longitude = longitude, zoom = zoom)

  if (is.null(tmp_lst$latitude) || is.null(tmp_lst$longitude) || tmp_lst$latitude == "" || tmp_lst$longitude == "") {                   # errors come mostly from this condition ( input values to shiny are converted to characters -- meaning that a NULL value is equal to "" )

    cat("'latitude' and 'longitude' should be a numeric non-NULL value", "\n")

    tmp_lst$latitude = 0.0          # assign an invalid latitude

    tmp_lst$longitude = 0.0         # assign an invalid longitude
  }

  tmp_lst_nams = c('lat=', 'lon=', 'zoom=')

  nominatim_query = "http://nominatim.openstreetmap.org/reverse?format=json"

  for (i in 1:length(tmp_lst)) {

    nominatim_query = paste(nominatim_query, paste(tmp_lst_nams[i], tmp_lst[[i]], sep = ""), sep = "&")
  }

  nominatim_query = paste(nominatim_query, "addressdetails=1", sep = "&")

  con = url(nominatim_query, method = "libcurl")

  tmp_json = suppressWarnings(readLines(con))

  if (tmp_json == "[]" || length(tmp_json) == 0) {               # In case that shiny closes unexpectedly check this condition, probably the resulted "df" is not '[]' or an empty one ( add a condition and use 'print(tmp_json)' to observe the behaviour )

    cat("the nominatim query returns an empty array. Please, modify the initial query", "\n")

    df = data.frame(address = NULL)

    rm(con); gc()}

  else {

    ex = geojsonR::shiny_from_JSON(tmp_json)

    if ('error' %in% names(ex)) {

      cat("Unable to geocode", '\n')

      df = data.frame(address = NULL)

      rm(con); gc()}

    else {

      df = c(ex$display_name, ex$lat, ex$lon)

      df = data.frame(matrix(df, nrow = 1, ncol = length(df)))

      colnames(df) = c('address', 'lat', 'lon')

      df$address = as.character(df$address)

      df$lat = as.numeric(as.character(df$lat))

      df$lon = as.numeric(as.character(df$lon))

      rm(con); gc()
    }
  }

  return(df)
}
