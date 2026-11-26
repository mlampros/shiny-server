
# LOGIN (disabled): on Shinylive / GitHub Pages the app runs in the browser, so a login
# cannot protect anything. Uncomment these lines to use it again on a Shiny server.
# shinymanager::secure_app(       # opening of the login wrapper
fluidPage(
  
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
        tabPanel("String Match",column(12, offset=1,h2=("String Matching"), tableOutput("dataOutput")))
      )
    )
  )
)
# )                              # closing of the login wrapper
