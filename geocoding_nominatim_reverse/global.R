
library(shiny)
library(geojsonR)
library(leaflet)

# LOGIN (disabled): on Shinylive / GitHub Pages the app runs in the browser, so a login
# cannot protect anything. Uncomment these lines to use it again on a Shiny server.
# library(shinymanager)
# library(scrypt)

# credentials <- data.frame(user = c("user"),
#                           password = c(scrypt::hashPassword("user")),
#                           is_hashed_password = TRUE,
#                           stringsAsFactors = FALSE)

# reverse_geocoding_nominatim function
reverse_geocoding_nominatim <- function(latitude = NULL, longitude = NULL, zoom = 0) {
  
  # Input validation
  if (is.null(latitude) || is.null(longitude) || 
      latitude == "" || longitude == "" || 
      is.na(latitude) || is.na(longitude)) {
    cat("'latitude' and 'longitude' should be numeric non-NULL values\n")
    return(data.frame(address = character(0), lat = numeric(0), lon = numeric(0)))
  }
  
  # Convert to numeric and validate
  tryCatch({
    lat_num <- as.numeric(latitude)
    lon_num <- as.numeric(longitude)
    zoom_num <- as.numeric(zoom)
    
    # Validate coordinate ranges
    if (is.na(lat_num) || is.na(lon_num) || 
        lat_num < -90 || lat_num > 90 || 
        lon_num < -180 || lon_num > 180) {
      cat("Invalid latitude (must be -90 to 90) or longitude (must be -180 to 180)\n")
      return(data.frame(address = character(0), lat = numeric(0), lon = numeric(0)))
    }
    
    # Validate zoom level
    if (is.na(zoom_num) || zoom_num < 0 || zoom_num > 18) {
      cat("Zoom parameter should be between 0 and 18, setting to default (10)\n")
      zoom_num <- 10
    }
    
  }, error = function(e) {
    cat("Error converting inputs to numeric values:", e$message, "\n")
    return(data.frame(address = character(0), lat = numeric(0), lon = numeric(0)))
  })
  
  # Build query URL
  nominatim_query <- sprintf(
    "https://nominatim.openstreetmap.org/reverse?format=json&lat=%f&lon=%f&zoom=%d&addressdetails=1",
    lat_num, lon_num, zoom_num
  )
  
  cat("Query URL:", nominatim_query, "\n")
  
  # Make API request with proper error handling
  tryCatch({
    tmp_json <- fetch_url_text(utils::URLencode(nominatim_query))
    
    if (length(tmp_json) == 0 || tmp_json == "[]") {
      cat("The nominatim query returns an empty array.\n")
      return(data.frame(address = character(0), lat = numeric(0), lon = numeric(0)))
    }
    
    ex <- geojsonR::shiny_from_JSON(tmp_json)
    
    if ('error' %in% names(ex)) {
      cat("Unable to geocode:", ex$error, "\n")
      return(data.frame(address = character(0), lat = numeric(0), lon = numeric(0)))
    }
    
    # Create result dataframe
    df <- data.frame(
      address = as.character(ex$display_name %||% "Unknown location"),
      lat = as.numeric(ex$lat %||% lat_num),
      lon = as.numeric(ex$lon %||% lon_num),
      stringsAsFactors = FALSE
    )
    
    return(df)
    
  }, error = function(e) {
    cat("Error in reverse geocoding:", e$message, "\n")
    return(data.frame(address = character(0), lat = numeric(0), lon = numeric(0)))
    
  })
}

# Helper function for null coalescing
`%||%` <- function(x, y) if (is.null(x)) y else x

# Download a URL as text. Works both in regular R and in the browser (webR / Shinylive),
# where base R's download.file() is routed through the browser (the server must allow CORS).
fetch_url_text <- function(u) {
  tmp <- tempfile(fileext = ".json")
  on.exit(unlink(tmp), add = TRUE)
  utils::download.file(u, tmp, quiet = TRUE, mode = "wb")
  paste(readLines(tmp, warn = FALSE, encoding = "UTF-8"), collapse = "")
}
