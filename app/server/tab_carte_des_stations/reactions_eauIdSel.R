observeEvent(rv$eauIdSel, {
  
  #### GEOM MASSE D'EAU ####
  # géométrie de la masse d'eau pompée par la station sélectionnée
  rv$eauGeom <- subset(eauUnion, cdmassedea == rv$eauIdSel)
  
  
  #### INFO AQUIFERE ####
  
  # nom de la masse d'eau cliquée
  rv$nomMasseDEau <- rv$eauSolProfil$nommassede[
    rv$eauSolProfil$cdmassedea == rv$eauIdSel
    ] %>%
    as.character()
  # nature de l'aquifère
  rv$typeMasseDEau <- rv$eauSolProfil$typemassed[
    rv$eauSolProfil$cdmassedea == rv$eauIdSel
    ] %>% as.character()
  
  
  #### PROFIL ####
  
  # stationIdSel <- rv$stationIdSel # pour pas que le graph soit recréé
  eauIdStation <- rv$eauIdStation
  eauSolProfil <- rv$eauSolProfil

  if(dim(eauSolProfil)[1]>0 & !is.null(rv$stationIdSel)){
    
    # profondeur du pompage
    stationZ <- stations@data%>%
      filter(cd_station == rv$stationIdSel) %>%
      select(profondeur_maxi_point)
    stationZ <- ifelse(is.na(stationZ),
                       "",
                       paste0("Prof.: ", stationZ %>% round, " m"))
    ## Tracé du profil
    output$profilSousSol <- renderPlot(bg="transparent", {
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
                                    profondeur_maxi_point = stationZ
        ),
        aes(x = x, y = y, label = profondeur_maxi_point),
        vjust = 0.5, hjust = 0, colour = "black", fontface = "bold") +
        scale_y_continuous(breaks=unique(eauSolProfil$niveau),
                           limits = c(10.5,-2), trans = "reverse",
                           label = function(x){return(paste("Niveau", x))})
    })
    
    #### UI ENCART MASSE D'EAU ####
  
    output$panelRecapMasseDEau <- renderUI({
      tagList(
        actionLink("questionMasseDEau",
                   label=
                     tagList(
                       h4("Masse d'eau sélectionnée", style = "display:inline;"),
                       icon("question-circle", "fa-2x")
                     )
        ),
        tags$p(style='margin-top:12px',
               tags$em("Nom aquifère(s) :"),
               rv$nomMasseDEau,
               tags$br(),
               tags$em("Nature aquifère(s) :"),
               rv$typeMasseDEau
        ),
        plotOutput('profilSousSol',  width = "200px",
                   click = "profilSousSol_click") 
      )
    })
  }
})


