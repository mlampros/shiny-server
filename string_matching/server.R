
shiny::shinyServer(function(input, output) {

  # # LOGIN (disabled): on Shinylive / GitHub Pages the app runs in the browser, so a login
  # cannot protect anything. Uncomment these lines to use it again on a Shiny server.
  # res_auth <- shinymanager::secure_server(
  #   check_credentials = shinymanager::check_credentials(credentials))

  output$dataOutput <- renderTable({

    existing <- c(input$existing_string_1, input$existing_string_2, input$existing_string_3)

    data <- data.frame(
      rep(input$new_string, 3),
      existing,
      stringdist(input$new_string, existing, method = "lv"),                         # Levenshtein distance
      sapply(existing, function(x) WRatio(input$new_string, x), USE.NAMES = FALSE),  # fuzzywuzzy WRatio (pure R port)
      stringsim(input$new_string, existing),                                         # similarity based on the Optimal String Alignment distance
      stringsAsFactors = FALSE
    )

    names(data) <- c("NEW STRING", "EXISTING-STRING", "LEVENSHTEIN-DISTANCE", "WRATIO (0-100)", "SIMILARITY (0-1)")
    data
  }, digits = 3)
})
