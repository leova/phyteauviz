output$filtresPestUI <- renderUI({
  div(class = "well",
      #### OE,stationIdSel: UI analyses: type an ####
      actionLink("questionTypesAnFonctionsStatut",
                 label= tagList(
                   h4(paste("Filtrer les ", dim(rv$pestStationStable)[1]," pesticides"), style = "display:inline"),
                   icon("question-circle", "fa-2x")
                 )
      ),
      checkboxGroupInput(inputId = "checkboxTypeAn",
                         label = "Par type de mesure",
                         choices = choixCB_typeAn,
                         selected = choixCB_typeAn),
      #### OE,stationIdSel: UI analyses: fonction pest ####
      checkboxGroupInput(inputId = "checkboxFoncPest",
                         label = "Par utilisation",
                         choices = choixCB_foncPest,
                         selected = choixCB_foncPest),
      #### OE,stationIdSel: UI analyses: statut pest ####
      checkboxGroupInput(inputId = "checkboxStatutPest",
                         label = "Par statut légal",
                         choices = choixCB_statutPest,
                         selected = choixCB_statutPest)
  )
})

#### OE,stationIdSel: UI graphQuantPestUI ####


output$graphQuantPestUI <- renderUI({
  
  div(class = "well",
      fluidRow(
        column(12,
          actionLink("questionSelectionPestPlot",
                     label=
                       tagList(
                         h4("Sélectionner les pesticides",
                            style="display:inline"),
                         icon("question-circle", "fa-2x")
                         )
                     # style="position:absolute;right:-14px;top:-5px"
          )
        )
        ),
        fluidRow(
          column(6, htmlOutput("selPestParNom")),
          column(6, 
                 selectizeInput(
                   "var1var2Selectize",
                   label = HTML('Par caractéristique<br/><span style="font-size: small">Choix des axes du graphique</span>'),
                   choices = choix_selectize,
                   multiple = T,
                   selected = c("MOY_STATION","DJA"),
                   options = list(maxItems = 2)
                 )
          )
        ),
        fluidRow(
               plotOutput("plotPest",
                          # width = "400px", height = "400px",
                          click = "clickPest",
                          hover = "hoverPest",
                          brush = "brushPest"),
               # message filtre pest
               htmlOutput("messageFiltrePest"),
               # reset sélection
               actionButton("resetPestSel", "Réinitialiser la sélection", style = "width: 50%;display: block;margin: 8px auto;"),
               # info pesticide quand "hover"
               tableOutput("hoveredPestTable")
        )
  )
})

output$panelAnalysesUIrow2 <- renderUI({
  fluidRow(
    column(12,
           div(class = "well",
               h4('Visualiser les pesticides sélectionnés'),
               tabsetPanel(
                 tabPanel("Tableau détaillé",
                          #### OE,stationIdSel: UI analyses: tableau ####
                          DT::dataTableOutput("dataTablePest")
                 ),
                 #### OE,stationIdSel: UI analyses: graph evol ####
                 tabPanel("Evolution de la concentration dans le temps",
                          actionLink("questionInterpConc",
                                     label="",
                                     icon = icon("question-circle", "fa-2x"),
                                     style='position: absolute;left:40px;'
                          ),
                          plotOutput("plotAn")
                 )
               )
           )
    )
  )
})