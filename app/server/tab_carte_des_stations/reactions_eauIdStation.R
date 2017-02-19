observeEvent(rv$eauIdStation, {
  
  if(is.null(rv$eauIdStation)){
    
    rv$nomMasseDEau <- ""
    rv$typeMasseDEau <- ""
  }else{
    ## afficher la div encart
    showElement("panelRecapStation")
    
    #### OE,eauIdSel: nom masse d'eau ####
    # nom de la masse d'eau cliquée
    rv$nomMasseDEau <- rv$eauSolProfil$nommassede[
      rv$eauSolProfil$cdmassedea == rv$eauIdSel
      ] %>%
      as.character()
    #### OE,eauIdSel: nature masse d'eau ####
    # nature de l'aquifère
    rv$typeMasseDEau <- rv$eauSolProfil$typemassed[
      rv$eauSolProfil$cdmassedea == rv$eauIdSel
      ] %>% as.character()
  }
  #### OE,eauIdSel: profil (tracé) ####
  stationIdSel <- rv$stationIdSel
  eauIdStation <- rv$eauIdStation
  eauSolProfil <- rv$eauSolProfil
  print(eauIdStation)
  print(dim(rv$eauSolProfil))
  if(dim(eauSolProfil)[1]>0 & !is.null(stationIdSel)){
    # profondeur du pompage
    stationZ <- stations@data%>%
      filter(CD_STATION == stationIdSel) %>%
      select(PROFONDEUR_MAXI_POINT)
    stationZ <- ifelse(is.na(stationZ),
                       "",
                       paste("Prof.: ", stationZ %>% round, "m", sep=""))
    ## Tracé du profil
    output$profilSousSol <- renderPlot(bg="transparent", {
      # isolate({
      profilSol +
        # le tuyau
        geom_line(data = data.frame(x=c(0.5,0.5),
                                    y=c(0,eauSolProfil$niveau[
                                      eauSolProfil$cdmassedea == eauIdStation]),
                                    id=rep("tuyau",2)),
                  aes(x = x, y = y, group = id), colour = "black", size = 1) +
        # les masses d'eau
        geom_hline(data = eauSolProfil, aes(yintercept=niveau, group = cdmassedea, alpha = alpha),
                   size = 4, colour = couleurMasseEau) +
        # la profondeur de la masse pompée par la station sélectionnée
        geom_text(data = data.frame(x = 0.2,
                                    y = eauSolProfil$niveau[
                                      eauSolProfil$cdmassedea == eauIdStation],
                                    PROFONDEUR_MAXI_POINT = stationZ
        ),
        aes(x = x, y = y, label = PROFONDEUR_MAXI_POINT),
        vjust = 0.5, hjust = 0, colour = "black", fontface = "bold") +
        scale_y_continuous(breaks=unique(eauSolProfil$niveau),
                           limits = c(10.5,-2), trans = "reverse",
                           label = function(x){return(paste("Niveau", x))})
      # })
    })
  }
  #### OE,eauIdSel: UI encart masse d'eau ####
  output$panelRecapMasseDEau <- renderUI({
    tagList(
      h4("Masse d'eau", style = "display:inline;"),
      actionLink("questionMasseDEau",
                 label="",
                 icon = icon("question-circle", "fa-2x"),
                 style='position: relative;left:25px'
      ),
      tags$p(style='margin-top:12px',
             tags$b("Nom aquifère(s) :"),
             rv$nomMasseDEau,
             tags$br(),
             tags$b("Nature aquifère(s) :"),
             rv$typeMasseDEau
      ),
      plotOutput('profilSousSol',  width = "200px",
                 click = "profilSousSol_click",
                 hover = "profilSousSol_hover")
    )
  })
})


#### OE,marker_click: eau geom ####
# géométrie de la masse d'eau pompée par la station sélectionnée
rv$eauGeom <- subset(eauUnion, cdmassedea == rv$eauIdSel)