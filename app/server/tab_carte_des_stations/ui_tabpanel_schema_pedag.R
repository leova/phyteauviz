observeEvent(input$fdroit,{
  if(rv$schemak < 3 ){
    rv$schemak <- rv$schemak + 1
  }else{
    rv$schemak <- 1
  }
})
observeEvent(input$fgauche,{
  if(rv$schemak > 1 ){
    rv$schemak <- rv$schemak - 1
  }else{
    rv$schemak <- 3
  }
})

output$panelPedagSchema <- renderUI({
  # indice schema précedent
  if(rv$schemak > 1 ){
    schemak_prec <- rv$schemak - 1
  }else{
    schemak_prec <- 3
  }
  # indice schema suivant
  if(rv$schemak < 3 ){
    schemak_suiv <- rv$schemak + 1
  }else{
    schemak_suiv <- 1
  }
  tagList(
    fluidRow(
      div(style="position: absolute; padding:0; top: 4px; bottom:54px; left:0; right:0;",
          img(src=paste0('schemas/', rv$schemak, '.png'), height="100%")
      )
    ),
    fluidRow(
      wellPanel(style="position: absolute; padding:0; height:50px; bottom:-20px; left:0; right:0;",
                column(3,
                       actionLink("fgauche",
                                  label = HTML(paste0(
                                    icon("chevron-left", "fa-2x"), ' ',
                                    schema$titre[schemak_prec], " (", schemak_prec, "/3)"
                                  )
                                  )
                       )
                ),
                column(6, style="padding:0px",
                       paste0("<b>",schema$titre[rv$schemak], "</b> (", rv$schemak, "/3)") %>% HTML
                ),
                column(3, style="padding:0px",
                       actionLink("fdroit",
                                  label = HTML(
                                    paste0(
                                      schema$titre[schemak_suiv], " (", schemak_suiv, "/3) ",
                                      icon("chevron-right", "fa-2x")
                                    )
                                  )
                       )
                )
      )
    )
  )
})