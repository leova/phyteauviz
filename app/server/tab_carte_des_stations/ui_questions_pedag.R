#### Pedag: UI (panel carte) ####
output$pedagPanelCarteUI <- renderUI({
  if(!is.null(rv$questionId)){
    tagList(
      actionLink(inputId = "closeButtonPedagCarte",
                 img(src = "close.png", class = "close_button")),
      readLines(paste("www/questions/", rv$questionId, ".html", sep ="")) %>% HTML
    )
  }
})

#### Pedag: UI (panel analyses) ####
output$pedagPanelAnalysesUI <- renderUI({
  if(!is.null(rv$questionId)){
    tagList(
      actionLink(inputId = "closeButtonPedagAnalyses",
                 img(src = "close.png", class = "close_button")),
      readLines(paste("www/questions/", rv$questionId, ".html", sep ="")) %>% HTML
    )
  }
})