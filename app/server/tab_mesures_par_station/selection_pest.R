#### SELECTION PAR NOM ####

observeEvent(input$pestNomInput,{

  pestStation <- rv$pestStation
  
  ### on actualise le statut de désélection des pesticides désélectionnés
  # id des pesticides à déselectionner
  pestDeselId <- setdiff(
    pestStation$CD_PARAMETRE[pestStation$selectionPest != "pas sélectionné"],
    input$pestNomInput
  )
  
  # déselection
  pestStation$selectionPest[
    pestStation$CD_PARAMETRE %in% pestDeselId
    ] <- rep("pas sélectionné", length(pestDeselId))
  pestStation$rayon[
    pestStation$CD_PARAMETRE %in% pestDeselId
    ] <- pestNSelRayon
  
  ### on actualise le statut de sélection des pesticides nouvellement sélectionnés
  # id des pesticides à sélectionner
  pestSelId <- setdiff(
    input$pestNomInput,
    pestStation$CD_PARAMETRE[pestStation$selectionPest != "pas sélectionné"]
  )
  
  # on sélectionne le pesticide non-déjà sélectionné si
  # le nombre maximum de pesticides sélectionnés n'est pas atteint
  
  if((pestSelValeurs %in% pestStation$selectionPest %>% sum ) < nMaxPest){
    # le n maximum de pesticides sélectionné n'est pas atteint
    
    pestStation$selectionPest[pestStation$CD_PARAMETRE == pestSelId] <-
      pestSelValeurs[!(pestSelValeurs %in% pestStation$selectionPest)][1]
    pestStation$rayon[pestStation$CD_PARAMETRE == pestSelId] <- pestSelRayon
  }
  
  rv$pestStation <- pestStation
})


#### SELECTION DEPUIS GRAPH: CLICK ####

## sélection des pesticides par click
# -> clickedPest = liste pesticides cliqués
observeEvent(input$clickPest, {
  
  ## réinitalisation message
  output$messageFiltrePest <- renderUI({""})
  
  ## pesticides cliqués
  clickedPest <- nearPoints(df = rv$pestStation %>% filter(visible),
                               coordinfo = input$clickPest,
                               xvar = input$var1var2Selectize[1],
                               yvar = input$var1var2Selectize[2],
                               threshold = 5)
  
  pestStation <- rv$pestStation
  
  pestStation[pestStation$CD_PARAMETRE == clickedPest$CD_PARAMETRE,] %>% print()
  
  if(dim(clickedPest)[1]>0){
    
    if( ((clickedPest$selectionPest != "pas sélectionné") %>% sum) > 0){
      # si parmis les pesticides clickés, 
      # il y en a au moins un qui est déjà sélectionné, 
      # tous sont désélectionnés
      
      pestStation$selectionPest[pestStation$CD_PARAMETRE %in% clickedPest$CD_PARAMETRE] <- 
        rep("pas sélectionné", dim(clickedPest)[1])
      pestStation$rayon[pestStation$CD_PARAMETRE %in% clickedPest$CD_PARAMETRE] <- pestNSelRayon
      
    }else{
      # sinon, on les sélectionne un par un tant que 
      # le nombre maximum de pesticides sélectionné n'est pas atteint
      kPest <- 1
      while( ( kPest <= dim(clickedPest)[1] ) &
             ( (pestSelValeurs %in% pestStation$selectionPest %>% sum ) < nMaxPest) ) # le n maximum de pesticides sélectionné n'est pas atteint
      {
        pestStation$selectionPest[pestStation$CD_PARAMETRE == clickedPest$CD_PARAMETRE[kPest]] <- 
          pestSelValeurs[!(pestSelValeurs %in% pestStation$selectionPest)][1]
        pestStation$rayon[pestStation$CD_PARAMETRE == clickedPest$CD_PARAMETRE[kPest]] <- 
          pestSelRayon
        
        kPest <- kPest + 1
        
      }
      
      if( (pestSelValeurs %in% pestStation$selectionPest %>% sum ) == nMaxPest){
        # le n maximum de pesticides sélectionnés est atteint
        output$messageFiltrePest <- renderUI({
          paste("Ne pas sélectionner plus de", nMaxPest, "pesticides à la fois")
        })
      }
      
      pestStation[pestStation$CD_PARAMETRE == clickedPest$CD_PARAMETRE,] %>% print()
    }
  }
  rv$pestStation <- pestStation
})


#### SELECTION DEPUIS GRAPH: BRUSH ####

## sélection des pesticides par click-glissé (brush)
# -> clickedPest = liste pesticides cliqués

observeEvent(input$brushPest,{

  ## réinitalisation message
  output$messageFiltrePest <- renderUI({""})
  
  ## pesticides cliqués (sélectionnés par brush)
  brushedPest <- brushedPoints(df = rv$pestStation %>% filter(visible),
                                  brush = input$brushPest,
                                  xvar = input$var1var2Selectize[1],
                                  yvar = input$var1var2Selectize[2]
  )
  pestStation <- rv$pestStation
  
    # sinon, on les sélectionne un par un tant que
    # le nombre maximum de pesticides sélectionné n'est pas atteint
    
    kPest <- 1
    while( (kPest <= dim(brushedPest)[1]) & 
           (pestSelValeurs %in% pestStation$selectionPest %>% sum < nMaxPest) # le n maximum de pesticides sélectionné n'est pas atteint
    ){
      
      pestStation$selectionPest[pestStation$CD_PARAMETRE == brushedPest$CD_PARAMETRE[kPest]] <-
        pestSelValeurs[!(pestSelValeurs %in% pestStation$selectionPest)][1]
      pestStation$rayon[pestStation$CD_PARAMETRE == brushedPest$CD_PARAMETRE[kPest]] <-
        pestSelRayon
      
      kPest <- kPest + 1
    }
    
    if(pestSelValeurs %in% pestStation$selectionPest %>% sum == nMaxPest){
      # le n maximum de pesticides sélectionnés est atteint
      output$messageFiltrePest <- renderUI({
        paste("Ne pas sélectionner plus de", nMaxPest, "pesticides à la fois")
      }) 
    }
  rv$pestStation <- pestStation
})

#### SELECTION PAR HOVERING ####
observeEvent(input$hoverPest,{
  selectize <- input$var1var2Selectize
  if(length(selectize) == 2){
    
    output$hoveredPestTable <- renderTable({
      hoveredPest <- nearPoints(df = rv$pestStation %>% filter(visible),
                                coordinfo = input$hoverPest,
                                xvar = selectize[1],
                                yvar = selectize[2],
                                threshold = 5)
      # remplacement des valeurs numérique manquantes (arbitrairement définies pour des fins d'affichage sur le graphe)
      # par "donnée manquante"
      hoveredPest[[ selectize[1] ]][
        hoveredPest[[ selectize[1] ]] == subset(
          paramPestFilt$table,indic == selectize[1]
        )$naVal
        ] <- "Donnée manquante"
      hoveredPest[[ selectize[2] ]][
        hoveredPest[[ selectize[2] ]] == subset(
          paramPestFilt$table,indic == selectize[2]
        )$naVal
        ] <- "Donnée manquante"
      
      # tableau "Pesticide", "<axe 1>", "<axe 2>"
      hoveredPest %>%
        select(LB_PARAMETRE,
               selectize[1] %>% as.name %>% eval,
               selectize[2] %>% as.name %>% eval) %>%
        rename(Pesticide = LB_PARAMETRE) %>%
        rename_(.dots=setNames(
          list(selectize[1],
               selectize[2]),
          list(
            subset(
              paramPestFilt$table,
              indic == selectize[1]
            )$indicateur %>% as.character,
            subset(
              paramPestFilt$table,
              indic == selectize[2]
            )$indicateur %>% as.character
          )
        )
        )
    })
  }
})


#### DESELECTION ####

observeEvent(input$resetPestSel,{
  rv$pestStation <- rv$pestStation %>%
    mutate(selectionPest = factor("pas sélectionné",
                                  levels = c("pas sélectionné", pestSelValeurs)),
           rayon = pestNSelRayon)
  output$messageFiltrePest <- renderUI({})
})