observeEvent(input$map_marker_click,{
  clickStation <- input$map_marker_click
  
  rvstations <- rv$stations
  
  if((rv$stations[["selection"]][rv$stations$CD_STATION == clickStation$id] == "click station") | 
     rv$stations[["selection"]][rv$stations$CD_STATION == clickStation$id] == "station profil" ){
    #### IF: station déjà sélectionnée ####
    
    ## masque du panneau des infos récapitulatives sur la station
    hideElement("panelRecapStation")
    
    ## réinitialisation du tabPanel "Mesures par station"
    output$filtresPestUI <- renderUI({})
    output$graphQuantPestUI <- renderUI({})
    output$panelAnalysesUIrow2 <- renderUI({})
    showElement("message_station_non_sel")
    
    ## effacement de l'identifiant de la station sélectionnée
    rv$stationIdSel <- ""
    
    ## réinitialisation des témoins de sélection
    rvstations[["selection"]] <-  F
    
    ## réinitialisation de l'identifiant de masse d'eau
    rv$eauIdSel <- ""
    
    ## réinitialisation du profil des masses d'eau
    rv$eauSolProfil <- data.frame()

  }else{
    
    #### ELSE: station pas sélectionnée ####
    
    ## afficher témoin chargement
    showElement(selector = ".chargement")
    
    ## enregistrement de l'identifiant de la station sélectionnée
    rv$stationIdSel <- clickStation$id
  
    
    #### MASSE D'EAU ANALYSEE ####
    
    ## obtention info station sélectionnée
    # info =
    # - communne, dep
    # - masse d'eau analysée

    selStation <- stations@data%>% filter(CD_STATION == rv$stationIdSel)

    # id de la masse d'eau analysée par la station
    # (CD_ME_v2 ou CD_ME_niv1_surf si CD_ME_v2 non renseignée)
    rv$eauIdStation <- ifelse(selStation$CD_ME_v2 == "",
                              selStation$CD_ME_niv1_surf %>% as.character(),
                              selStation$CD_ME_v2 %>% as.character())

    ## la masse d'eau sélectionnée devient celle analysée par la station
    rv$eauIdSel <- rv$eauIdStation
    # remarque: rv$eauIdSel n'est pas nécessairement rv$eauIdStation
    # puisque une autre masse d'eau pourra ensuite être sélectionnée depuis le profil
    
    
    #### TEMOINS SELECTIONS ####
    
    ## gestion des témoins de sélection
    
    # réinitialisation 
    rvstations[["selection"]] <- F
    
    # "eau" = témoin de sélection de toutes les stations qui analysent la masse d'eau
    rvstations[["selection"]][
      rvstations@data %>% filter( 
        # stations effectuant des analyses dans la masse d'eau sélectionnée
        # (renseignée dans le champs CD_ME_v2)
        (CD_ME_v2 == rv$eauIdSel %>% as.character()) |
          # ou
          # stations pour lesquelles CD_ME_v2 n'est pas renseigné
          # mais dont CD_ME_niv1_surf est celui de la couche analysée
          ((CD_ME_niv1_surf == rv$eauIdSel %>% as.character()) &
             (CD_ME_v2 == ""))
      ) %>% 
        select(index) %>% unlist
      ] <- "eau"
    
    # "click station" = témoin de sélection de la station sélectionnée
    rvstations[["selection"]][rvstations$CD_STATION == clickStation$id] <- "click station"
    
    
    #### PROFIL EAU ####
    
    ## selectionner l'ensemble des masses d'eau sous la station (df, non spatial)
    
    clickStationSp <- SpatialPoints(cbind(clickStation$lng,clickStation$lat),
                                    proj4string = eau@proj4string)
    eauSolProfil <- over(clickStationSp, eau, returnList = T)[['1']]
    
    ## gestion du bug: la station n'est pas située exactement au dessus de la masse d'eau dans laquelle elle pompe
    # Cette opération génère des potentielles erreurs dans les niveaux relatifs des masses d'eau
    
    if(!(rv$eauIdStation %in% eauSolProfil$cdmassedea)){
      print("la masse d'eau pompée par la station n'est pas présente dans le profil")
      
      infoMasseDEauStation <- subset(eau, cdmassedea == rv$eauIdStation)@data
      infoMasseDEauStation <- infoMasseDEauStation[1,] # pour les masses d'eau sur plusieurs niveaux, on ne garde qu'un niveau
      
      if(infoMasseDEauStation$niveau %in% eauSolProfil$niveau){
        print("le niveau de la masse d'eau pompée par la station est déjà dans le profil")
        # le niveau de la masse d'eau pompée par la station est déjà dans le profil
        
        if(dim(eauSolProfil)[1] > 1){
          print("il y a plus d'un niveau dans le profil")
          # il y a plus d'un niveau dans le profil
          eauSolProfil <- rbind(
            # -> on supprime la masse d'eau
            eauSolProfil %>%
              filter(niveau != infoMasseDEauStation$niveau),
            # -> pour la remplacer par celle de la station
            infoMasseDEauStation)
          
        }else{
          print("il y a moins d'un niveau dans le profil")
          # il y a moins d'un niveau dans le profil
          # -> on remplace le profil par la masse d'eau pompée par la station
          eauSolProfil <- infoMasseDEauStation
        }
        
      }else{
        print("le niveau de la masse d'eau pompée n'est pas présent dans le profil")
        # le niveau de la masse d'eau pompée n'est pas présent dans le profil
        # on ajoute la masse d'eau pompée par la station
        eauSolProfil <- rbind(eauSolProfil, infoMasseDEauStation)
      }
    }
    
    eauSolProfil$alpha <- 0.8
    eauSolProfil$alpha[eauSolProfil$cdmassedea == rv$eauIdSel] <- 1
    
    rv$eauSolProfil <- eauSolProfil

  }
  rv$stations <- rvstations
})