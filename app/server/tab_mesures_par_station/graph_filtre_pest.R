##### OBSERVEEVENT input$var1var2Selectize: structure graph #####
#### OE,var1var2SelectizeGraph: structure
observeEvent(input$var1var2Selectize,{
  if(length(input$var1var2Selectize) == 2){
    
    # calcul des limites du graphe
    minMaxX <- minmaxGraphPest(inputvarselectize = input$var1var2Selectize[1],
                               rvPestStation = rv$pestStation,
                               paramPestFiltZones = paramPestFilt$zones)
    minMaxY <- minmaxGraphPest(inputvarselectize = input$var1var2Selectize[2],
                               rvPestStation = rv$pestStation,
                               paramPestFiltZones = paramPestFilt$zones)
    
    # les labels des axes, sont placés au centre des intervales
    # entre 2 droites verticales ou horizontales
    posiTextX <- positionText(
      minMax = minMaxX,
      inputvarselectize = input$var1var2Selectize[1],
      paramPestFiltZones = paramPestFilt$zones,
      f = paramPestFilt$table$axeTrans[ paramPestFilt$table$indic == input$var1var2Selectize[1] ])
    posiTextY <- positionText(
      minMax = minMaxY,
      inputvarselectize = input$var1var2Selectize[2],
      paramPestFiltZones = paramPestFilt$zones,
      f = paramPestFilt$table$axeTrans[ paramPestFilt$table$indic == input$var1var2Selectize[2] ])
    
    rv$plotPest <- ggplot(rv$pestStation %>% filter(visible)) +
      scale_x_continuous(name = subset(paramPestFilt$table,
                                       indic == input$var1var2Selectize[1])$indicateur,
                         limits = c(minMaxX$min, minMaxX$max),
                         breaks = posiTextX,
                         labels = paramPestFilt$zones[[input$var1var2Selectize[1]]]$labels,
                         trans = subset(paramPestFilt$table,
                                        indic == input$var1var2Selectize[1])$axeTrans) +
      scale_y_continuous(name=subset(paramPestFilt$table,
                                     indic == input$var1var2Selectize[2])$indicateur,
                         limits = c(minMaxY$min, minMaxY$max),
                         breaks = posiTextY,
                         labels = paramPestFilt$zones[[input$var1var2Selectize[2]]]$labels,
                         trans = subset(paramPestFilt$table,
                                        indic == input$var1var2Selectize[2])$axeTrans
      ) +
      geom_vline(data = paramPestFilt$zones[[input$var1var2Selectize[1]]][["limitesdf"]],
                 aes(xintercept = limites),
                 size = 1, colour = grey(0.1)) +
      geom_hline(data = paramPestFilt$zones[[input$var1var2Selectize[2]]][["limitesdf"]],
                 aes(yintercept = limites),
                 size = 1, colour = grey(0.1)) +
      themeGraphPest
  }
})



#### RENDERPLOT plotPest: geom_points ####
#### Graph pest: ajout points
output$plotPest <- renderPlot({
  
  if(length(input$var1var2Selectize) == 2){
    rv$plotPest +
      geom_point(data = rv$pestStation %>% filter(visible),
                 aes(x = eval(as.name(input$var1var2Selectize[1])),
                     y = input$var1var2Selectize[2] %>%
                       as.name %>% eval,
                     colour = selectionPest,
                     size = rayon),
                 alpha = 0.8,
                 position = position_dodge(width = 0.01)) +
      echelleCoulPest
  }
},bg="transparent")