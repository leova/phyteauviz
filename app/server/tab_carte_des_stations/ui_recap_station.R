### OE,stationIdSel: UI encart recap station (an)
output$panelRecapAn <- renderUI({
  tagList(
    h4("Station", style="display:inline"),
    actionLink("go2tabAn",label = 
                 tagList(
                   icon("bar-chart", "fa-2x"),
                   tags$em("Voir les mesures")
                 ),
               style="position: relative;float: right;"),
    tags$div(style='margin-top:10px',
           tags$em("Commune :"),
           paste(commune$nom_com[1], " (",
                 formatC(commune$num_dep[1] %>% as.character() %>% as.numeric,
                         width = 2, format = "g", flag = "0"),
                 ")", sep=''),
           tags$br(),
           tags$em("Campagnes de mesures :"),
           renderPlot(bg = "transparent",height = 100,{
                 recapStationNbPrelAn
           }),
           tags$em(paste('<b>', dim(rv$anStation)[1],"mesures</b> ont détecté<b>",
                 dim(rv$pestStationStable)[1],
                 "pesticides</b> dont :") %>% HTML
           )
    ),
    fluidRow(
      column(3, style="padding:0 0 0 5px;position:relative;left:30px;",
             h5("Types de mesure"),
             renderPlot(bg = "transparent",height = 83,{
               recapStationTypeAnPlot
             })
      ),
      column(9,style="padding:0",
             paste0(
               '<ul style="list-style-type:none;">',#position:relative;left:-70px;">',
               paste0('<li style="font-size:small;">',
                      # cadre couleur
                      '<svg width="15" height="15" style="position:relative;top:5px"><rect width="15" height="15" style="fill:',
                      recapStationTypeAn$couleur,
                      ';stroke:black;stroke-width:1;opacity:1;display:inline-block" /></svg>',
                      # nombre pest par type d'analyse
                      ' <b>',recapStationTypeAn$nPest,'</b> ',recapStationTypeAn$labels,
                      '</li>',
                      collapse = ""
               ),'</span></ul>'
             ) %>% HTML
      )
    ),
    fluidRow(
      column(3, style="padding:0 0 0 5px;position:relative;left:30px;",
             h5("Fonctions"),
             renderPlot(bg = "transparent",height = 83,{
               recapStationFoncPlot
             })
      ),
      column(9,style="padding:0",
             paste0(
               '<ul style="list-style-type:none;">',#position:relative;left:-70px;">',
               paste0('<li style="font-size:small;">',
                      # cadre couleur
                      '<svg width="15" height="15" style="position:relative;top:5px"><rect width="15" height="15" style="fill:',
                      recapStationFonc$couleur,
                      ';stroke:black;stroke-width:1;opacity:1;display:inline-block" /></svg>',
                      # nombre pest par fonction
                      ' <b>',recapStationFonc$nPest,'</b> ',recapStationFonc$labels,
                      '</li>',
                      collapse = ""
               ),'</span></ul>'
             ) %>% HTML
      )
    ),
    fluidRow(
      column(3, style="padding:0 0 0 5px;position:relative;left:30px;",
             h5("Statut légal"),
             renderPlot(bg = "transparent",height = 83,{
               recapStationStatutPlot
             })
      ),
      column(9,style="padding:0",
             paste0(
               '<ul style="list-style-type:none;">',#position:relative;left:-70px;">',
               paste0('<li style="font-size:small;">',
                      # cadre couleur
                      '<svg width="15" height="15" style="position:relative;top:5px"><rect width="15" height="15" style="fill:',
                      recapStationStatut$couleur,
                      ';stroke:black;stroke-width:1;opacity:1;display:inline-block" /></svg>',
                      # nombre pest par statut
                      ' <b>',recapStationStatut$nPest,'</b> ',recapStationStatut$labels,
                      '</li>',
                      collapse = ""
               ),'</span></ul>'
             ) %>% HTML
      )
    )
  )
}) #renderUI

hideElement(selector = '.chargement')