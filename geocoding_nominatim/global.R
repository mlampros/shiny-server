
library(shiny)
library(leaflet)
library(geojsonR)
library(shinymanager)
library(scrypt)

credentials <- data.frame(user = c("user"),
                          password = c(scrypt::hashPassword("user")),
                          is_hashed_password = TRUE,
                          stringsAsFactors = FALSE)

# address_geocoding_nominatim function
address_geocoding_nominatim <- function(streetname = NULL, housenumber = NULL, city = NULL, 
                                        county = NULL, state = NULL, country = NULL, 
                                        postalcode = NULL) {
  
  # Check if at least one parameter has meaningful content
  all_params <- list(streetname, housenumber, city, county, state, country, postalcode)
  has_content <- any(sapply(all_params, function(x) !is.null(x) && nchar(trimws(x)) > 0))
  
  if (!has_content) {
    return(data.frame(display_name = character(0)))
  }
  
  nominatim_query <- "http://nominatim.openstreetmap.org/search?format=json"
  
  # Handle street and house number
  STREET <- "&street="
  flag_number <- FALSE
  
  if (!is.null(housenumber) && nchar(trimws(housenumber)) > 0) {
    STREET <- paste0(STREET, trimws(housenumber))
    flag_number <- TRUE
  }
  
  if (!is.null(streetname) && nchar(trimws(streetname)) > 0) {
    if_sep <- ifelse(flag_number, " ", "")
    STREET <- paste(STREET, trimws(streetname), sep = if_sep)
  }
  
  # Only add street if there's actual content
  if (flag_number || (!is.null(streetname) && nchar(trimws(streetname)) > 0)) {
    nominatim_query <- paste(nominatim_query, STREET, sep = "")
  }
  
  # Handle other parameters
  tmp_lst <- list(city, county, state, country, postalcode)
  tmp_lst_nams <- c('city=', 'county=', 'state=', 'country=', 'postalcode=')
  
  for (i in 1:length(tmp_lst)) {
    if (!is.null(tmp_lst[[i]]) && nchar(trimws(tmp_lst[[i]])) > 0) {
      nominatim_query <- paste(nominatim_query, 
                               paste(tmp_lst_nams[i], trimws(tmp_lst[[i]]), sep = ""), 
                               sep = "&")
    }
  }
  
  # Create connection and handle errors properly
  con <- NULL
  tryCatch({
    con <- url(nominatim_query, method = "libcurl")
    tmp_json <- suppressWarnings(readLines(con))
    
    if (length(tmp_json) == 0 || tmp_json == "[]") {
      cat("The nominatim query returns an empty array. Please modify the query.\n")
      return(data.frame(display_name = character(0)))
    }
    
    ex <- geojsonR::shiny_from_JSON(tmp_json)
    
    df <- data.frame(do.call(rbind, lapply(ex, function(x) {
      c(unlist(x['boundingbox']), x['display_name'], x['importance'], x['lat'], x['lon'])
    })))
    
    colnames(df) <- c('South_LATItude', 'North_LATItude', 'West_LONGitude', 
                      'East_LONGitude', 'display_name', 'importance', 'lat', 'lon')
    
    df <- df[order(as.numeric(df$importance), decreasing = TRUE), ]
    return(df)
    
  }, error = function(e) {
    cat("Error in geocoding:", e$message, "\n")
    return(data.frame(display_name = character(0)))
    
  }, finally = {
    if (!is.null(con)) {
      try(close(con), silent = TRUE)
    }
    gc()
  })
}