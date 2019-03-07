library(shiny)
library(stringdist)
# library(fuzzywuzzyR)
library(reticulate)

py_install(c("fuzzywuzzy", "python-Levenshtein"), method = "auto", conda = "auto")
FUZZ <- reticulate::import("fuzzywuzzy.fuzz", delay_load = TRUE)

shinyServer(function(input, output) {
  
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