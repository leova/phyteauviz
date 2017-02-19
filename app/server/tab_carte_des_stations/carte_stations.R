#### renderLeaflet: initialisation ####
output$map <- renderLeaflet({
  leaflet() %>%
    addTiles() %>%
    setView(lng = -0.5, lat = 46.6, zoom = 6) %>% 
    addLegend(position = "bottomright",
              title = "Concentration totale annuelle <br/>mesurée par station",
              pal = pal, values = c(0,500),
              labFormat = labelFormat(digits = 2,
                                      suffix = ' µg/l'))
})

#### Markers stations ####
# couleur remplissage = concentration moyenne annuelle totale par station
# opacité remplissage = transparente si pas d'analyse durant l'année
# couleur, rayon, epaisseur du tracé du cercle = témoin de sélection d'une station et/ou d'une masse d'eau

observeEvent(c(stationsVis(), input$sliderAnnee), {

  leafletProxy('map') %>%
    # afficher les markers
    addCircleMarkers(data = stationsVis(), 
                     group = "markersStations",
                     layerId = ~CD_STATION,
                     # stroke
                     radius = ~ifelse(selection == F | selection == "station profil", 5, 8),
                     weight = ~ifelse(selection != F, 3, 1),
                     color = ~ifelse(selection == "eau",
                                     couleurMasseEau,
                                     ifelse(selection == "click station" |
                                              selection == "station profil",
                                            pal(
                                              eval(as.name(paste0("moy",input$sliderAnnee)))
                                            ), "#777777")),
                     opacity = ~ifelse(selection, 0.7, 0.9),
                     # fill
                     fillColor = ~pal(
                       eval(as.name(paste0("moy",input$sliderAnnee)))
                     ), 
                     fillOpacity = ~ifelse(eval(as.name(paste0("moy",input$sliderAnnee))) %>% is.na, 
                                           0, 0.7)
    )
})

#### Carte: géométrie masse d'eau (OE eauGeom) ####
# tracer la géométrie de la masse d'eau quand
#     - une station est sélectionnée
#     - ou une masse d'eau est sélectionnée depuis le profil
observeEvent(rv$eauGeom, {
  leafletProxy('map') %>%
    # afficher les masses d'eau
    clearGroup("polygoneEau") %>%
    addPolygons(data = rv$eauGeom,
                group = "polygoneEau",
                color = couleurMasseEau, opacity = 0.8,
                weight = 1) %>%
    # afficher les stations par dessus la masse d'eau
    clearGroup("markersStations") %>%
    addCircleMarkers(data = stationsVis(), 
                     group = "markersStations",
                     layerId = ~CD_STATION,
                     # stroke
                     radius = ~ifelse(selection == F | selection == "station profil", 5, 8),
                     weight = ~ifelse(selection != F, 3, 1),
                     color = ~ifelse(selection == "eau",
                                     couleurMasseEau,
                                     ifelse(selection == "click station" |
                                              selection == "station profil",
                                            pal(
                                              eval(as.name(paste0("moy",input$sliderAnnee)))
                                            ), "#777777")),
                     opacity = ~ifelse(selection, 0.7, 0.9),
                     # fill
                     fillColor = ~pal(
                       eval(as.name(paste0("moy",input$sliderAnnee)))
                     ), 
                     fillOpacity = ~ifelse(eval(as.name(paste0("moy",input$sliderAnnee))) %>% is.na, 
                                           0, 0.7)
                     )
})