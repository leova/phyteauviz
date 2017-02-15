tabPanel("Mesures par station", value = "anPan", tags$head(includeCSS("www/style.css")), useShinyjs(),
         div(class = "outer_mesu_par_station",
             wellPanel(
               id = "message_station_non_sel",
               style="text-align:center",
               width= "40%",
               "Sélectionner d'abord une station de mesure sur la carte"
             ),
             fluidRow(
               column(4,
                      htmlOutput("filtresPestUI")
               ),
               column(8,
                      htmlOutput("graphQuantPestUI")
               )
             ),
             htmlOutput("panelAnalysesUIrow2"),
             div(class="pedag", id="pedagPanelAnalyses",
                 div(class = "pedag_popup",
                     htmlOutput("pedagPanelAnalysesUI")
                     )
             )
         )
)