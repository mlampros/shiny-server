library(shiny)
library(stringdist)
library(fuzzywuzzyR)
library(reticulate)
use_virtualenv("/home/rstudio/anaconda3/envs/my_env35")
py_install(c("fuzzywuzzy","virtualenv"), method = "auto", conda = "auto")
import("fuzzywuzzy")
import("virtualenv")

shinyServer(function(input, output) {
  
  init <- FuzzMatcher$new()
  
  output$dataOutput <- renderDataTable({
    
    data <- data.frame(c(input$new_string,input$new_string,input$new_string),
                       c(input$existing_string_1,input$existing_string_2,input$existing_string_3),
                       c(stringdist(input$new_string,input$existing_string_1,method = "lv"),stringdist(input$new_string,input$existing_string_2,method = "lv"),stringdist(input$new_string,input$existing_string_3,method = "lv")),
                       c(init$WRATIO(input$new_string,input$existing_string_1),init$WRATIO(input$new_string,input$existing_string_2),init$WRATIO(input$new_string,input$existing_string_3)),
                       c(stringsim(input$new_string,input$existing_string_1),stringsim(input$new_string,input$existing_string_2),stringsim(input$new_string,input$existing_string_3)))
    
    names(data) <- c("NEW STRING","EXISTING-STRING","RESULT-1","RESULT-2","RESULT-3")
    data
    
  })
})