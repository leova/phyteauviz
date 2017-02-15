observeEvent(rv$pestStation,{
  
  pestSel <- rv$pestStation %>%
    filter(selectionPest != "pas sélectionné")
  
  
  #### AFFICHER PESTICIDES SELECTIONNES DANS SELECTINPUT-NOM-PEST ####
  
  choix_pest <- rv$pestStation %>%
    filter(visible) %>%
    select(CD_PARAMETRE) %>% unlist()
  names(choix_pest) <- rv$pestStation %>%
    filter(visible) %>%
    select(LB_PARAMETRE) %>% unlist
  selected_pest <- rv$pestStation %>%
    filter(selectionPest != "pas sélectionné") %>%
    select(CD_PARAMETRE) %>% unlist()

  output$selPestParNom <- renderUI({
    selectizeInput(inputId = "pestNomInput", label = "Par nom",
                   choices = choix_pest,
                   selected = selected_pest,
                   multiple = T
    )
  })
  
  if(dim(pestSel)[1]>0){
    
    #### TABLEAU PEST SEL ####
    pestSel <- left_join(
      pestSel,
      data.frame(CODE_COULEUR = couleursPest,
                 selectionPest = names(couleursPest)),
      by = "selectionPest"
    )
    
    output$dataTablePest <- DT::renderDataTable(
      pestSel %>%
        select(CODE_FONCTION, CODE_FAMILLE, NOM_PARENT,
               STATUT, NBAN_STATION,
               NBQUANTIF_STATION, MOY_STATION, MOY_NAT,
               DJA, KOC, DT50Champs)%>%
        mutate(
          MOY_STATION =  format(MOY_STATION, digits=2, decimal.mark= ','),
          MOY_NAT =  format(MOY_NAT, digits=2, decimal.mark = ','),
          DJA = ifelse(DJA == 999, "donnée manquante", DJA),
          KOC = ifelse(KOC == 1e10, "donnée manquante", KOC),
          DT50Champs = ifelse(DT50Champs == 9999, "donnée manquante", DT50Champs),
          STATUT = recode(STATUT,
                          PNA = "non-autorisé",
                          PA = "autorisé",
                          NoData = "pas d'information",
                          SO = "SO"),
          CODE_FONCTION = recode(CODE_FONCTION,
                                 F="fongicide", FN="fongicide, nématocide", H="herbicide",
                                 I="insecticide", IA="insecticide, acaricide",
                                 IAFH="insectide, acarcide, fongicide, herbicide",
                                 IAM="insecticide, acaricide, mollusticide",
                                 IAN="insecticide, acaricide, nématocide",
                                 IN="insecticide, nématocide",
                                 Ireg="insecticide, régulateur de croissance",
                                 R="Rodenticide", Reg="régulateur de croissance",
                                 RepO="Répulsif", Ro="rodenticide", X="donnée manquante")
        ),
      escape = F,
      colnames = c(
        "Famille" = "CODE_FAMILLE",
        "Métabolite<br/>dérivé de" = "NOM_PARENT",
        "Fonction" = "CODE_FONCTION",
        "Statut" = "STATUT",
        "DJA<br/>(toxicité)<br/>mg/kg/jour" = "DJA",
        "KOC<br/>(mobilité)<br/>L/g" = "KOC",
        "DT50 Champs<br/>(dégradabilité)<br/>jour" = "DT50Champs",
        "Nombre d'analyses<br/>" = "NBAN_STATION",
        "Nombre d'analyses<br/>quantifiées" = "NBQUANTIF_STATION",
        "Concentration moyenne<br/>(station)<br/>µg/L" = "MOY_STATION",
        "Concentration moyenne<br/>(nationale)<br/>µg/L" = "MOY_NAT"
      ),
      rownames = paste(
        sapply(pestSel$CODE_COULEUR,
               function(x){
                 paste0(
                   '<svg width="20" height="20"><rect width="20" height="20"',
                   'style="display: inline; fill:',
                   x,
                   ';stroke:black;stroke-width:1;opacity:1;display:inline-block" /></svg>'
                 )
               }),
        paste0('<b>',pestSel$LB_PARAMETRE,'</b>')
      ),
      options = list(
        paging = F,
        searching = F,
        scrollX = T,
        ordering = T
      )
    )
  }
  
  
  #### GRAPH EVOL PEST ####
  
  # rv$pestStation$CD_PARAMETRE[rv$pestStation$selectionPest != "pas sélectionné"]
  anStationFilt <- rv$anStation %>%
    filter(CD_PARAMETRE %in% pestSel$CD_PARAMETRE) %>%
    # on ajoute la colonne qui gère la couleur des pesticides sélectionnés
    left_join(pestSel, by = "CD_PARAMETRE")
  
  output$plotAn <- renderPlot(bg="transparent",{
    ggplot(anStationFilt,
           aes(x=ANNEE, y = MA_MOY,
               colour = selectionPest,
               group = as.factor(CD_PARAMETRE))) +
      geom_hline(yintercept = 0.1, size = 1, colour = "#CC0000") +
      geom_point(#position = position_dodge(width = .3),
        size = 5) +
      geom_line() +
      scale_y_continuous(limits = c(0,NA),
                         name = "Concentration annuelle moyenne (µg/L)") +
      scale_x_continuous(breaks = 2007:2014,
                         limits = c(2006.5, 2014.5)) +
      scale_colour_manual(
        name = "Pesticide(s) sélectionné(s)",
        values = couleursPest,
        breaks= pestSel$selectionPest,
        labels= pestSel$LB_PARAMETRE
      ) +
      themeGraphAn
    
  })
})