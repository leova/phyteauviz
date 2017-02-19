observeEvent(rv$stationIdSel, {
  
  if(rv$stationIdSel != ""){
    
    ##### ENCART RECAP STATION #####
    
    #### NB PRELEVEMENTS PAR AN ####
    
    nbPrelAnDf <- stations$nbprel[stations$CD_STATION == rv$stationIdSel][[1]]
    
    recapStationNbPrelAn <- ggplot(data = nbPrelAnDf, 
                                   aes(x = variable, y = value)) +
      geom_bar(stat = "identity", fill=grey(0.3), width = 0.4) +
      scale_y_continuous(name = "Nombre de\nprélévements",
                         breaks = c(0, 
                                    unique(nbPrelAnDf$value[ !is.na(nbPrelAnDf$value) ]
                                           )
                         )
      ) +
      scale_x_discrete(labels = 2007:2014) +
      theme(axis.title.x = element_blank(),
            panel.background = element_rect(fill = "transparent",colour = NA),
            plot.background = element_rect(fill = "transparent",colour = NA),
            axis.ticks = element_blank(),
            axis.text = element_text(size = unit(10,'pt')),
            axis.title.y =  element_text(angle = 0, hjust = 1, vjust = 0.5),
            panel.grid.minor = element_blank(),
            panel.grid.major = element_blank(),
            panel.spacing = unit(c(0,0,0,0), "pt"),
            legend.position = "none")
    
    #### MESURES EFFECTUEES SUR LA STATION ####
    rv$anStation <- an %>% filter(CD_STATION == rv$stationIdSel)
    
    #### PESTICIDES DETECTES DANS STATION ####
    ## info sur les pesticides analysés dans la station
    ## pour filtrer les analyses
    
    idPestStation <- rv$anStation$CD_PARAMETRE %>% unique()
    
    rv$pestStation <- pest %>%
      ### enlever les pesticides non-analysés par la station
      filter(CD_PARAMETRE %in% idPestStation) %>%
      ### ajout concentration moyenne du pesticide pour
      ### l'ensemble de la campagne de mesures sur la station
      inner_join(rv$anStation %>%
                   group_by(CD_PARAMETRE) %>%
                   summarise(MOY_STATION = mean(MA_MOY)),
                 by = "CD_PARAMETRE") %>%
      ### calcul de la différence par rapport à la moyenne nationale
      mutate(DIFF_NAT = MOY_STATION - MOY_NAT)  %>%
      ### calcul de l'evolution de la concentration de chaque pesticide
      ### l'évolution de la concentration est caractérisée par
      ### le coefficient directeur (ug/l/an) de la droite de régression "concentration = a * année + b"
      inner_join(
        rv$anStation %>%
          group_by(CD_PARAMETRE) %>%
          do(mylms = lm(MA_MOY ~ ANNEE, data = .)) %>%
          mutate(EVOL_STATION = ifelse(is.na(coef(mylms)[2]), 0,  coef(mylms)[2])) %>%
          select(-mylms),
        by = "CD_PARAMETRE"
      ) %>%
      inner_join(
        ## Calcul
        # - NBAN_STATION; nombre de fois que le pesticide a été analysé
        # par une station au cours des campagnes
        # - NBQUANTIF_STATION : nombre de fois que le pesticide à été quantifié
        # - anType: type de l'analyse
        rv$anStation %>%
          group_by(CD_PARAMETRE) %>%
          summarise(
            NBAN_STATION = sum(NBANASPERTS1),
            NBQUANTIF_STATION = sum(NBQUANTIF),
            typeAn = ifelse(
              # au moins une année avec une analyse quantifiée et une analyse au dessus de 0.1
              (sum(NBQUANTIF > 0) > 0) &
                (sum(MA_MOY > 0.1) > 0), "QUANTIFSUPDCE_STATION",
              ifelse(
                # au moins une année avec une analyse quantifiée
                sum(NBQUANTIF > 0) > 0, "QUANTIFINFDCE_STATION",
                ifelse(
                  # au moins une année avec une concentration moyenne excédant la norme
                  sum(MA_MOY > 0.1) > 0, "DETECSUPDCE_STATION",
                  # que des analysés non quantifiées, estimée en deça de la norme
                  "DETECINFDCE_STATION"
                )
              )
            )
          ),
        by = "CD_PARAMETRE"
      ) %>%
      # ajout d'un booleen indiquant si le pestcide est masqué ou affiché
      # et du statut de sélection
      mutate(visible = T,
             selectionPest = factor("pas sélectionné",
                                    levels = c("pas sélectionné", pestSelValeurs)),
             rayon = pestNSelRayon)
    
    #### PESTICIDES DETECTES DANS STATION - STABLE ####
    
    ### tableau des pesticides par station utilisé uniquement pour filtrer
    ## sans champs qui peuvent être modifiés
    ## (ainsi, les filtres ne sont pas recréés à chaque fois
    ## que rv$pestStation est modifié)
    rv$pestStationStable <- rv$pestStation %>%
      select(-visible, -selectionPest, - rayon)
    
    #### COMMUNE ####
    commune <- stations@data%>%
      filter(CD_STATION == rv$stationIdSel) %>%
      select(NOM_COM, NUM_DEP)
    
    if(dim(rv$anStation)[1] > 0){ 
      ## on va plus loin dans le détail des mesures réalisées 
      # dans la station que si il y en a, cf cas de VOGUE (07)
      # stations@data %>% filter(CD_STATION == "08656X0005/S")
      # an %>% filter(CD_STATION == "08656X0005/S")
      
      #### TYPES D'ANALYSE ####
      ### recapStationTypeAn 
      ### données pour camembert types d'analyses
      
      recapStationTypeAn <- rv$pestStationStable$typeAn %>%
        table %>%
        melt()
      
      names(recapStationTypeAn) <- c("typeAn", "nPest")
      
      recapStationTypeAn <- left_join(recapStationTypeAn %>% mutate(typeAn = as.factor(typeAn)),
                                      typeAnDf,
                                      by = "typeAn")
      
      choix_typeAn <- recapStationTypeAn$typeAn ; names(choix_typeAn) <- recapStationTypeAn$labels
      choixCB_typeAn <- choix_typeAn
      names(choixCB_typeAn) <- paste(recapStationTypeAn$nPest, names(choixCB_typeAn))
      
      ### camembert types d'analyses
      recapStationTypeAnPlot <- recapStationPlot(recapStationTypeAn, "typeAn", scaleTypeAn)
      
      #### FONCTION PESTICIDE ####
      ### OE,stationIdSel: recapStationFonc
      ### données pour camembert fontions des pesticides trouvés sur station
      recapStationFonc <- data.frame(
        fonctionsPestDf,
        nPest = sapply(fonctionsPestDf$fonc,
                       function(x) grepl(x, rv$pestStationStable$CODE_FONCTION) %>% sum)
      ) %>%
        filter(nPest > 0)
      
      choix_foncPest <- recapStationFonc$fonc ; names(choix_foncPest) <- recapStationFonc$labels
      choixCB_foncPest <- choix_foncPest %>% as.character()
      names(choixCB_foncPest) <- paste(recapStationFonc$nPest, names(choix_foncPest))
      
      ### camembert types d'analyses
      recapStationFoncPlot <- recapStationPlot(recapStationFonc, "fonc", scaleFoncPest)
      
      #### STATUT LEGAL PESTICIDE ####
      ### OE,stationIdSel: recapStationStatut
      ### données pour camembert statuts des pesticides trouvés sur station
      recapStationStatut <- rv$pestStationStable$STATUT %>%
        table %>%
        melt(); names(recapStationStatut) <- c("statut", "nPest")
      recapStationStatut <- recapStationStatut[c(2,3,1),] # changer ordre affichage (alphabétique -> PA, PNA, NoData)
      recapStationStatut <- left_join(recapStationStatut %>% mutate(statut = as.factor(statut)),
                                      statutPestDF,
                                      by = "statut")
      
      choix_statutPest <- recapStationStatut$statut ; names(choix_statutPest) <- recapStationStatut$labels
      choixCB_statutPest <- choix_statutPest %>% as.character
      names(choixCB_statutPest) <- paste(recapStationStatut$nPest, names(choix_statutPest))
      
      ### camembert types d'analyses
      recapStationStatutPlot <- recapStationPlot(recapStationStatut, "statut", scaleStatutPest)
      
      
      #### UI ENCART RECAP AN ####
      hideElement("message_station_non_sel")
      source(file.path("server/tab_carte_des_stations", "ui_recap_station.R"),  local = TRUE)$value
      
      #### UI TABPANEL MESURES STATION ####
      source(file.path("server/tab_mesures_par_station", "ui_tabPanel_mesures_station.R"),  local = TRUE)$value  
    }else{
      output$panelRecapAn <- renderUI({
        tagList(
          h4("Station"),
          tags$p(style='margin-top:10px',
                 tags$em("Commune :"),
                 paste(commune$NOM_COM[1], " (",
                       formatC(commune$NUM_DEP[1] %>% as.character() %>% as.numeric,
                               width = 2, format = "g", flag = "0"),
                       ")", sep=''), tags$br(),
                 tags$em("Campagnes de mesures :"), tags$br(),
                 tags$b('Pas de mesures disponibles')
          )
        )
      })
    } # fin if-else(dim(rv$anStation)[1] > 0){
    
    ## affichage du panneau des infos récapitulatives sur la station
    showElement("panelRecapStation")
    showElement("closePanelRecapStation")
    hideElement("openPanelRecapStation")
    showElement("panelRecapAn")
    showElement("panelRecapMasseDEau")
    
  }
})