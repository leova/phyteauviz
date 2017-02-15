#### OBSERVEEVENT FILTRES input$checkboxes ####

#### OE,checkbox* (filtres) ####
observeEvent(c(input$checkboxTypeAn,
               input$checkboxFoncPest,
               input$checkboxStatutPest),{
                 pestStation <- rv$pestStation
                 
                 # initialisation
                 pestStation$visible <- T
                 
                 # masque type d'analyse
                 pestStation$visible[!(pestStation$typeAn %in% input$checkboxTypeAn)] <- F
                 
                 # masque fonction pesticide
                 pestStation$visible[
                   !(grepl(paste(input$checkboxFoncPest,
                                 collapse = "|"), pestStation$CODE_FONCTION))
                   ] <- F
                 
                 # masque statut pesticide
                 pestStation$visible[
                   !(pestStation$STATUT %in% input$checkboxStatutPest)
                   ] <- F
                 
                 # désélection des pesticides précédemment sélectionnés (par click)
                 # qui viennent d'être masqués
                 pestStation$selectionPest[
                   !(pestStation$CD_PARAMETRE %in%
                       pestStation$CD_PARAMETRE[ pestStation$visible ] # pesticides visibles
                   )
                   ] <- factor("pas sélectionné",
                               levels = c("pas sélectionné", pestSelValeurs))
                 pestStation$rayon[
                   !(pestStation$CD_PARAMETRE %in%
                       pestStation$CD_PARAMETRE[ pestStation$visible ] # pesticides visibles
                   )
                   ] <- pestNSelRayon
                 
                 rv$pestStation <- pestStation
                 
               })