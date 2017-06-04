#### libraries_et_donnees.R ####
# chargement des 
# - librairies
# - données
source(file.path("server", "librairies_et_donnees.R"))

#### parametres_et_metadonnees.R ####
# chargement des 
# - paramètres
# - échelles de couleusr
# - metadonnées (info complémentaires sur colonnes jeux de données)
source(file.path("server", "parametres_et_metadonnees.R"))

#### fonctions.R ####
# chargement des fonctions
source(file.path("server", "fonctions.R"))

#### INTERFACE UTILISATEUR ####
ui <- navbarPage(
  title = "Phyt'eau viz", id = "navBar",
  # tabPanels
  source(file.path("ui", "tabPanel_carte_des_stations.R"),  local = TRUE)$value,
  source(file.path("ui", "tabPanel_mesures_par_station.R"),  local = TRUE)$value,
  tabPanel("Pour comprendre", value = "questionsPan",
           div(class = "outerPedag", 
               htmlOutput("panelPedagSchema",style="display:inline")
           )
  ),
  tabPanel("A propos",
           readLines(paste("www/", "A_propos.html", sep ="")) %>% HTML 
  )
  
)

#### SERVER ####

server <- function(input, output, session) {
  
  #### Masquer le disclaimer ####
  onclick("outerDisclaimer", {
    hideElement("outerDisclaimer")  
  })
  
  #### aller du disclaimer à "à propos" ####
  observeEvent(input$switchVersAPropos,{
    updateNavbarPage(session = session, inputId = "navBar", selected = "A propos")
  })
  
  #### reactive_values.R ####
  # rv <- reactiveValues()
  # initialise certains objets "réactifs"
  source(file.path("server", "reactive_values.R"),  local = TRUE)$value
  
  #### carte_stations.R ####
  # renderLeaflet
  # - fond de carte OSM
  # - légende
  # observeEvent(c(stationsVis(), input$sliderAnnee), {
  # -> ajout des markers stations en fonction du zoom, de l'année
  # })
  # observeEvent(eauGeom, {
  # -> tracer de la géométrie de la masse d'eau sélectionnée
  # }
  source(file.path("server/tab_carte_des_stations", "carte_stations.R"),  local = TRUE)$value
  
  #### filtre_stations.R ####
  # stationsVis <- reactive(zoom bbox)
  # -> retourne les stations visibles (en fonction du zoom et de la bbox)
  source(file.path("server/tab_carte_des_stations", "filtre_stations.R"),  local = TRUE)$value
  
  #### click_station.R ####
  # observeEvent(input$map_marker_click, {
  # -> réinitialisation des interfaces lorsqu'une station est désélectionnée
  # -> gestion témoins de sélection
  # -> rv$stationIdSel
  # -> rv$eauIdStation
  # -> rv$eauIdSel
  # })
  source(file.path("server/tab_carte_des_stations", "click_station.R"),  local = TRUE)$value

  #### reactions_stationIdSel.R ####
  # observeEvent(rv$stationIdSel,{
  # -> rv$anStation
  # -> commune
  # -> rv$pestStation
  # -> rv$pestStationStable
  # -> recapStationTypeAn, choix_typeAn, recapStationTypeAnPlot
  # -> recapStationFonc, choix_foncPest, recapStationFoncPlot
  # -> recapStationStatut, choix_statutPest, recapStationStatutPlot
  # -> source('ui_recap_station.R') ( output$panelRecapAn <- renderUI({...}) )
  # -> showElement("panelRecapStation")
  # })
  source(file.path("server/tab_carte_des_stations", "reactions_stationIdSel.R"),  local = TRUE)$value
  
  #### reactions_eauIdSel.R ####
  # observeEvent(rv$eauIdSel,{
  # -> rv$eauGeom
  # -> output$profilSousSol
  # })
  source(file.path("server/tab_carte_des_stations", "reactions_eauIdSel.R"),  local = TRUE)$value
  
  #### click_profil.R ####
  ## Lorsqu'une masse d'eau est sélectionnée sur le profil des eaux souterraines,
  # -> rv$eauIdSel: afficher géométrie de la nouvelle masse d'eau
  # -> rv$stations: sur la carte, colorer les stations qui pompent dans la nappe d'eau sélectionnée
  # -> rv$eauSolProfil: déselectionner la station (+envelever couleur de sélection du markeur)
  source(file.path("server/tab_carte_des_stations", "click_profil.R"),  local = TRUE)$value
  
  #### graph_filtre_pest.R ####
  # observeEvent(input$var1var2Selectize,{
  # -> définition des axes / zones du graphe / position du texte
  # -> tracé du graphe
  # }
  # output$plotPest <- renderPlot({
  # -> ajout des points
  # }
  source(file.path("server/tab_mesures_par_station", "graph_filtre_pest.R"),  local = TRUE)$value
  
  ### filtre_pest.R ####
  # observeEvent(checkbox*,{
  # -> rv$pestStation $visible, $rayon
  # }
  source(file.path("server/tab_mesures_par_station", "filtre_pest.R"),  local = TRUE)$value
  
  #### selection_pest.R ####
  # selection par nom:
  # observeEvent(input$pestNomInput,{ 
  # -> rv$pestStation
  # }
  # selection depuis le graphe: 
  # observeEvent(input$clickPest & input$brushPest, {
  # -> rv$clickedPest pesticides cliqués
  # })
  # observeEvent(rv$clickedPest, {
  # -> rv$pestStation
  # }
  # observeEvent(input$hoverPest,{
  # -> hoveredPest
  # }
  source(file.path("server/tab_mesures_par_station", "selection_pest.R"),  local = TRUE)$value
  
  #### reactions_pestStation.R ####
  # output$selPestParNom <- renderUI({selectInput...})
  source(file.path("server/tab_mesures_par_station", "reactions_pestStation.R"),  local = TRUE)$value
  
  #### clicks_liens.R ####
  # - tabPanel "Carte" -> tabpanel "Graphes"
  # - question "masse d'eau" -> tabpanel "pour comprendre"
  # - tous les points d'interrogation
  # - boutton fermer cadre question
  source(file.path("server/tab_carte_des_stations", "click_liens.R"),  local = TRUE)$value
  
  #### ui_questions_pedag.R ####
  # output$pedagPanelCarteUI <- renderUI({...})
  # output$pedagPanelAnalysesUI <- renderUI({...})
  source(file.path("server/tab_carte_des_stations", "ui_questions_pedag.R"),  local = TRUE)$value
  
  #### ui_tabpanel_pedag.R ####
  # observeEvent(input$fdroit/input$fgauche,{...})
  # output$panelPedagSchema <- renderUI({...})
  source(file.path("server/tab_carte_des_stations", "ui_tabpanel_schema_pedag.R"),  local = TRUE)$value

}

shinyApp(ui = ui, server = server)
