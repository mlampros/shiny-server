
# REFERENCE: https://github.com/ranikay/shiny-reticulate-app

library(shiny)
library(stringdist)
# library(fuzzywuzzyR)
# library(reticulate)

# reticulate::py_install(c("fuzzywuzzy", "python-Levenshtein"), method = "auto", conda = "auto")    # for 'py_install()' see: https://community.rstudio.com/t/trouble-using-python-packages-with-reticulate-and-shinyapps-io/11728/2
# FUZZ <- reticulate::import("fuzzywuzzy.fuzz", delay_load = TRUE)

# Define any Python packages needed for the app here:
PYTHON_DEPENDENCIES = c("fuzzywuzzy", "python-Levenshtein")

shinyServer(function(input, output) {

  virtualenv_dir = Sys.getenv('VIRTUALENV_NAME')
  python_path = Sys.getenv('PYTHON_PATH')

  # Create virtual env and install dependencies
  reticulate::virtualenv_create(envname = virtualenv_dir, python = python_path)
  reticulate::virtualenv_install(virtualenv_dir, packages = PYTHON_DEPENDENCIES, ignore_installed=TRUE)
  reticulate::use_virtualenv(virtualenv_dir, required = T)

  FUZZ <- reticulate::import("fuzzywuzzy.fuzz", delay_load = TRUE)

  output$dataOutput <- renderDataTable({

    # init <- FuzzMatcher$new()

    data <- data.frame(c(input$new_string,input$new_string,input$new_string),
                       c(input$existing_string_1,input$existing_string_2,input$existing_string_3),
                       c(stringdist(input$new_string,input$existing_string_1,method = "lv"),stringdist(input$new_string,input$existing_string_2,method = "lv"),stringdist(input$new_string,input$existing_string_3,method = "lv")),
                       # c(init$WRATIO(input$new_string,input$existing_string_1),init$WRATIO(input$new_string,input$existing_string_2), init$WRATIO(input$new_string,input$existing_string_3)),
                       c(FUZZ$WRatio(input$new_string,input$existing_string_1),FUZZ$WRatio(input$new_string,input$existing_string_2), FUZZ$WRatio(input$new_string,input$existing_string_3)),
                       c(stringsim(input$new_string,input$existing_string_1),stringsim(input$new_string,input$existing_string_2),stringsim(input$new_string,input$existing_string_3)))

    names(data) <- c("NEW STRING","EXISTING-STRING","RESULT-1","RESULT-2","RESULT-3")
    data
  })
})
