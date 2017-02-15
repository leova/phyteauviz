#### FONCTIONS ####

# renvoie l'id de la masse d'eau sélectionnée sur le profil
getEauIdCurseur <- function(massesDEau, valeurCurseur){
  distancesClick <- abs( massesDEau$niveau - valeurCurseur)
  minDist <- min(distancesClick)
  if(minDist < 0.3){
    return(massesDEau$cdmassedea[distancesClick == minDist])
  }else{
    return(NULL)
  }
}

minmaxGraphPest <- function(inputvarselectize, rvPestStation, paramPestFiltZones){
  pct <- 0.3
  minVal <- (1 - pct) * min(c(
    # la plus petite valeur du jeu de données
    rvPestStation %>%
      filter(visible) %>%
      select(
        eval(as.name(inputvarselectize))
      ) %>% unlist(),
    # ou, la plus petite limite (valeur significative)
    # représentée sur le graph par une ligne verticale.
    # pour laisser un marge, on enlève x %
    paramPestFiltZones[[inputvarselectize]]$limites[1] %>% unlist
  )
  )
  maxVal <- (1 + pct) * max(c(
    # la plus grande valeur du jeu de données
    rvPestStation %>%
      filter(visible) %>%
      select(
        eval(as.name(inputvarselectize))
      ) %>% unlist(),
    # ou, la plus grande limite (valeur significative)
    # représentée sur le graph par une ligne verticale.
    # pour laisser un marge, on ajoute x %
    paramPestFiltZones[[inputvarselectize]]$limites[
      length(paramPestFiltZones[[inputvarselectize]]$limites)
      ] %>% unlist
  )
  )
  return(list(min = minVal , max = maxVal))
}

## retourne la position des labels pour le graph
positionText <- function(minMax, # valeur min et max de l'axe
                         inputvarselectize, # l'indicateur quantitatif de l'axe correspondant
                         paramPestFiltZones, # objet avec les parametre pour chaque indicateur quanti
                         f = "identity"){
  if(f == "log"){
    out <- exp(
      (
        log(
          c(minMax$min,
            paramPestFiltZones[[inputvarselectize]]$limites %>% unlist
          )
        ) +
          log(
            c(paramPestFiltZones[[inputvarselectize]]$limites %>% unlist,
              minMax$max)
          )
      ) / 2
    )
    
  }else{
    
    out <- (
      c(
        minMax$min,
        paramPestFiltZones[[inputvarselectize]]$limites %>% unlist
      ) +
        c(
          paramPestFiltZones[[inputvarselectize]]$limites %>% unlist,
          minMax$max
        )
    ) / 2
  }
  return(out)
}

# retourne un camembert avec la proportion de pesticides en chacun des parametres
recapStationPlot <- function(recapTable, parametre, echelleParametre){
  ggplot(recapTable) +
    geom_bar(aes(x = factor(1), y = nPest,
                 fill = factor(
                   parametre %>% as.name %>% eval
                 )),
             stat="identity",
             width=1) +
    coord_polar(theta = "y" ) +
    echelleParametre +
    theme(panel.grid = element_blank(),
          panel.background = element_rect(fill = "transparent",colour = NA),
          plot.background = element_rect(fill = "transparent",colour = NA),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          plot.margin = unit(c(0, 0, 0, 0), "pt"),
          panel.spacing = unit(c(0,0,0,0), "pt"),
          legend.position = "none"
    )
}

masquerShinyInputs <- function(){
  hideElement("sliderAnnee")
  hideElement("selPestParNom")
  hideElement("var1var2Selectize")
}

afficherShinyInputs <- function(){
  showElement("sliderAnnee")
  showElement("selPestParNom")
  showElement("var1var2Selectize")
}