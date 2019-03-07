library(shiny)

shinyUI(fluidPage(
  
  titlePanel(tags$u(strong(h2("FUZZY LOGIC"),align = "center"))),
  
  sidebarLayout(
    sidebarPanel(
      conditionalPanel(condition = "$('li.active a').first().html()==='String Match'",
                       submitButton("Submit", icon("refresh")),
                       
                       tags$u(tags$header(strong(h3("Enter Input Strings")))),
                       
                       textInput("existing_string_1", "Enter Existing String-1",placeholder = "Please enter the text here...!!!"),
                       textInput("existing_string_2", "Enter Existing String-2",placeholder = "Please enter the text here...!!!"),
                       textInput("existing_string_3", "Enter Existing String-3",placeholder = "Please enter the text here...!!!"),
                       textInput("new_string", "Enter New String",placeholder = "Please enter the text here...!!!")
                       
      )
      ,width = 3),
    
    mainPanel(
      
      tabsetPanel(
        tabPanel("String Match",column(12, offset=1,h2=("String Matching"), dataTableOutput("dataOutput")))
      )
    )
  )
))