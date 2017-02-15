#### Switch tabPanel "Carte" -> tabpanel "Graphes" ####
observeEvent(input$go2tabAn,{
  updateNavbarPage(session = session, inputId = "navBar", selected = "anPan")
})

#### Switch question masse d'eau -> pour comprendre ####
observeEvent(input$switchQuestion2PourComprendre,{
  hideElement(selector = ".pedag")
  updateNavbarPage(session = session, inputId = "navBar", selected = "questionsPan")
})

#### RecapPanelStation: toggle cadre ####
observeEvent(input$closePanelRecapStation, {
  hideElement("panelRecapAn")
  hideElement("panelRecapMasseDEau")
  hideElement("closePanelRecapStation")
  showElement("openPanelRecapStation")
})
observeEvent(input$openPanelRecapStation, {
  showElement("closePanelRecapStation")
  hideElement("openPanelRecapStation")
  showElement("panelRecapAn")
  showElement("panelRecapMasseDEau")
})

#### Pedag: question masse d'eau ####
observeEvent(input$questionMasseDEau,{
  rv$questionId <- "questionMasseDEau"
  showElement(selector = ".pedag"); showElement(selector = ".pedag_popup")
  masquerShinyInputs()
})

#### Pedag: question stations de mesure ####
observeEvent(input$questionStationMesure,{
  rv$questionId <- "questionStationMesure"
  showElement(selector = ".pedag"); showElement(selector = ".pedag_popup")
  masquerShinyInputs()
})

#### Pedag: question types analyses ####
observeEvent(input$questionTypesAnFonctionsStatut,{
  rv$questionId <- "questionTypesAnFonctionsStatut"
  showElement(selector = ".pedag"); showElement(selector = ".pedag_popup")
  masquerShinyInputs()
})

#### Pedag: question statut ####
observeEvent(input$questionStatut,{
  rv$questionId <- "questionStatut"
  showElement(selector = ".pedag"); showElement(selector = ".pedag_popup")
  masquerShinyInputs()
})

#### Pedag: question indicateurs qualitatifs ####
observeEvent(input$questionIndicateursQuantiPest,{
  rv$questionId <- "questionIndicateursQuantiPest"
  showElement(selector = ".pedag"); showElement(selector = ".pedag_popup")
  masquerShinyInputs()
})

#### Pedag: question interprétation evol ####
observeEvent(input$questionInterpConc,{
  rv$questionId <- "questionInterpConc"
  showElement(selector = ".pedag"); showElement(selector = ".pedag_popup")
  masquerShinyInputs()
})

#### Pedag: question comment sélectionner les pesticides ####
observeEvent(input$questionSelectionPestPlot,{
  rv$questionId <- "questionSelectionPestPlot"
  showElement(selector = ".pedag"); showElement(selector = ".pedag_popup")
  masquerShinyInputs()
})

#### Pedag: question normes DCE ####
observeEvent(input$questionNormeDCE,{
  rv$questionId <- "questionNormeDCE"
  showElement(selector = ".pedag"); showElement(selector = ".pedag_popup")
  masquerShinyInputs()
})

#### Pedag: fermer cadre ####
observeEvent(input$closeButtonPedagCarte, {
  hideElement(selector = ".pedag")
  afficherShinyInputs()
})
observeEvent(input$closeButtonPedagAnalyses, {
  hideElement(selector = ".pedag")
  afficherShinyInputs()
})