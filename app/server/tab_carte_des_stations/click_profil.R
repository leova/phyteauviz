### Station (encart): Profil (click)
## Lorsqu'une masse d'eau est sélectionnée sur le profil des eaux souterraines,
#   - afficher géométrie de la nouvelle masse d'eau
#   - déselectionner la station (+envelever couleur de sélectiion du markeur)
#   - sur la carte, colorer les stations qui pompent dans la nappe d'eau sélectionnée

observeEvent(input$profilSousSol_click$y, {
  eauIdClick <- getEauIdCurseur(rv$eauSolProfil, input$profilSousSol_click$y)
  if( !is.null(eauIdClick) &
      eauIdClick != rv$eauIdSel ){
    # une couche a été sélectionnée par l'utilisateur et ce n'est pas la même que celle déjà affichée
    
    # identifiant de la masse d'eau cliquée
    rv$eauIdSel <- eauIdClick
    
    # # géométrie de la masse d'eau clickée
    # rv$eauGeom <- subset(eauUnion, cdmassedea == rv$eauIdSel)
    
    # profil: faire ressortir masse d'eau cliquée
    eauSolProfil <- rv$eauSolProfil
    eauSolProfil$alpha <- ifelse(eauSolProfil$cdmassedea == rv$eauIdSel,1,0.8)
    rv$eauSolProfil <- eauSolProfil
    
    # selectionner les stations qui analysent la masse d'eau sélectionnée
    # c'est à dire:
    # - soit, les stations qui ont pour CD_ME_v2 l'identifiant de la station
    # - soit, si CD_ME_v2 n'est pas renseigné, CD_ME_niv1 = l'identifiant
    # - on déselectionne les stations précédemment sélectionnées
    
    rvstations <- rv$stations
    
    # on désélectionne les stations qui pompent dans la masse d'eau précédemment sélectionnée
    # (sauf la station correspondant au profil de sol)
    rvstations[["selection"]][ rvstations$selection == "eau" ] <- F
    # la station dont le profil sous-terrain est dessiné change de statut
    # (permet de changer le diamètre du marker sans changer le reste)
    rvstations[["selection"]][ rvstations$selection == "click station" ] <- "station profil"
    
    # on sélectionne toutes les stations qui analysent la nouvelle masse d'eau
    rvstations[["selection"]][
      rvstations$cd_station %in% (
        stations@data%>%
          filter( (cd_me_v2 == rv$eauIdSel %>% as.character()) |
                    ((cd_me_niv1_surf == rv$eauIdSel %>% as.character()) &
                       (cd_me_v2 == "")) ) %>%
          filter(cd_station != rv$stationIdSel) %>% # mais on ne change pas le témoin de sélection de la station sélectionnée 
          select(cd_station) %>% unlist)
      ] <- "eau"
    rv$stations <- rvstations
    
  }
})