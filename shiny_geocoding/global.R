
library(shiny); library(geojsonR)


# secondary function for the 'geocoding_nominatim()' function
#

address_geocoding_nominatim = function(streetname = NULL, housenumber = NULL, city = NULL, county = NULL,

                                       state = NULL, country = NULL, postalcode = NULL) {

  nominatim_query = "http://nominatim.openstreetmap.org/search?format=json"

  STREET = "&street="

  flag_number = F

  if (!is.null(housenumber)) {

    STREET = paste0(STREET, housenumber)

    flag_number = T
  }

  if (!is.null(streetname)) {

    if_sep = ifelse(flag_number, " ", "")

    STREET = paste(STREET, streetname, sep = if_sep)
  }

  if (!is.null(streetname) || !is.null(housenumber)) {

    nominatim_query = paste(nominatim_query, STREET, sep = "")
  }

  tmp_lst = list(city, county, state, country, postalcode)

  tmp_lst_nams = c('city=', 'county=', 'state=', 'country=', 'postalcode=')

  for (i in 1:length(tmp_lst)) {

    if (!is.null(tmp_lst[[i]])) {

      nominatim_query = paste(nominatim_query, paste(tmp_lst_nams[i], tmp_lst[[i]], sep = ""), sep = "&")
    }
  }

  con = url(nominatim_query, method = "libcurl")

  tmp_json = suppressWarnings(readLines(con))

  if (tmp_json == "[]" || length(tmp_json) == 0) {               # In case that shiny closes unexpectedly check this condition, probably the resulted "df" is not '[]' or an empty one ( add a condition and use 'print(tmp_json)' to observe the behaviour )

    cat("the nominatim query returns an empty array. Please, modify the initial query", "\n")

    rm(con); gc()

    df = data.frame(display_name = NULL)

    return(df)}

  else {

    ex = geojsonR::shiny_from_JSON(tmp_json)

    df = data.frame(do.call(rbind, lapply(ex, function(x) c(unlist(x['boundingbox']), x['display_name'], x['importance'], x['lat'], x['lon']))))

    colnames(df) = c('South_LATItude', 'North_LATItude', 'West_LONGitude', 'East_LONGitude', 'display_name', 'importance', 'lat', 'lon')

    df = df[order(unlist(df$importance), decreasing = T), ]

    rm(con); gc()

    return(df)
  }
}


