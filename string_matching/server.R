# REFERENCE: https://github.com/ranikay/shiny-reticulate-app

library(shiny)
library(stringdist)
library(shinymanager)
library(scrypt)

credentials <- data.frame(user = c("user"),
                          password = c(scrypt::hashPassword("user")),
                          is_hashed_password = TRUE,
                          stringsAsFactors = FALSE)

# Define any Python packages needed for the app here:
PYTHON_DEPENDENCIES = c("fuzzywuzzy", "python-Levenshtein")

shiny::shinyServer(function(input, output) {
  
  res_auth <- shinymanager::secure_server(
    check_credentials = shinymanager::check_credentials(credentials))  
  
  # let reticulate auto-detect Python and install packages
  tryCatch({
    # Install packages using auto-detected Python
    reticulate::py_install(PYTHON_DEPENDENCIES, method = "auto")
  }, error = function(e) {
    message("Package installation failed: ", e$message)
  })
  
  # Import the fuzzywuzzy module with error handling
  FUZZ <- NULL
  tryCatch({
    FUZZ <- reticulate::import("fuzzywuzzy.fuzz", delay_load = TRUE)
  }, error = function(e) {
    message("Failed to import fuzzywuzzy: ", e$message)
  })
  
  output$dataOutput <- renderDataTable({
    
    # Create the data frame
    data <- data.frame(
      c(input$new_string, input$new_string, input$new_string),
      c(input$existing_string_1, input$existing_string_2, input$existing_string_3),
      c(
        stringdist(input$new_string, input$existing_string_1, method = "lv"),
        stringdist(input$new_string, input$existing_string_2, method = "lv"),
        stringdist(input$new_string, input$existing_string_3, method = "lv")
      ),
      # Use fuzzywuzzy if available, otherwise use R-based alternative
      if (!is.null(FUZZ)) {
        c(
          FUZZ$WRatio(input$new_string, input$existing_string_1),
          FUZZ$WRatio(input$new_string, input$existing_string_2), 
          FUZZ$WRatio(input$new_string, input$existing_string_3)
        )
      } else {
        # Fallback to R-based fuzzy matching (Jaro-Winkler similarity * 100)
        c(
          round((1 - stringdist(input$new_string, input$existing_string_1, method = "jw")) * 100),
          round((1 - stringdist(input$new_string, input$existing_string_2, method = "jw")) * 100),
          round((1 - stringdist(input$new_string, input$existing_string_3, method = "jw")) * 100)
        )
      },
      c(
        stringsim(input$new_string, input$existing_string_1),
        stringsim(input$new_string, input$existing_string_2),
        stringsim(input$new_string, input$existing_string_3)
      )
    )
    
    names(data) <- c("NEW STRING", "EXISTING-STRING", "RESULT-1", "RESULT-2", "RESULT-3")
    data
  })
})