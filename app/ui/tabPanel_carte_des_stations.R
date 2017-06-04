tabPanel("Carte des stations", value = "carte", useShinyjs(),
         div(class="outer",
             tags$head(includeCSS("www/style.css")),
             leafletOutput('map', width = "100%", height = "100%"),
             absolutePanel(id="sliderAnneePanel", top=10, left=60, width="350px", style = "padding-bottom:0",
                           sliderInput('sliderAnnee', 
                                       label = 
                                         actionLink("questionStationMesure", 
                                                    label=tagList(
                                                      "Campagne de mesure",
                                                      icon("question-circle", "fa-2x")
                                                    )
                                       ),
                                       width = '100%',
                                       min = 2007, max = 2014, value = 2014, step = 1,
                                       sep = '', ticks = F,
                                       animate = animationOptions(interval = 1000)
                           )
             ),
             absolutePanel(id="panelRecapStation",
                           fluidRow(
                             tagList(
                               actionLink(inputId = "closePanelRecapStation", 
                                          class = "togglePanelRecapStation",
                                          label = tagList(
                                           tags$em("masquer"),
                                           icon("external-link-square", "fa-rotate-180 fa-2x")
                                          )
                                          
                               ),
                               actionLink(inputId = "openPanelRecapStation", 
                                          class = "togglePanelRecapStation",
                                          style = 'display: none;',
                                          label = tagList(
                                            tags$em("afficher les informations sur la station"),
                                            icon("external-link-square", "fa-2x")
                                          )
                               )
                             )
                           ),
                           fluidRow(
                             column(7,
                                    htmlOutput("panelRecapAn")
                             ),
                             column(5,
                                    htmlOutput("panelRecapMasseDEau")
                             ) 
                           )
             )
         ),
         div(class="pedag", id="pedagPanelCarte",
             div(class = "pedag_popup",
                 htmlOutput("pedagPanelCarteUI")
             )
         ),
         div(class="chargement", 
             p(icon("spinner", "fa-pulse fa-3x fa-fw"))
         ),
         div(id="outerDisclaimer",
             div(class="disclaimer",
                 h1(style='color:#334364;', strong('Phyt\'eau Viz')),
                 h2('Outil de ', strong('visualisation'),' des données sur les ',strong('pesticides dans les eaux souterraines')),
                 p(style = 'margin-top: 1cm',
                   'Cet outil a été développé dans le cadre d\'un ',
                   strong(a('concours', target="_blank", href = 'http://www.developpement-durable.gouv.fr/concours-data-visualisation-sur-pesticides-dans-eaux-souterraines')),
                   'et est un ',em(style='text-decoration:underline','site expérimental'),'.
                 Il est possible que vous rencontriez des bugs et/ou des problèmes d\'accès serveurs. Ce prototype a été testé avec Mozilla Firefox.'),
                 p('Nous prévoyons une phase de développement pour corriger les problèmes de navigation et la rendre plus intuitive. 
                  Aussi, ', actionLink("switchVersAPropos", strong('vos retours nous intéressent'))),
                 p(style = 'margin-top: 1cm; text-align:center', strong('Bonne navigation !'))
             )
         )
)