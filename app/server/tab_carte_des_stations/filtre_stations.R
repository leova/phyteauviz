#### stationsVis <- reactive(zoom bbox) ####
# Filtrer les stations
# en fonction du zoom et de la bbox

stationsVis <- reactive({
  rv$stations
  zoomSeuil <- 6 # zoom seuil pour ne pas surcharger la carte
  # on ne sélectionne des stations que si on a suffisamment zoomé
  zoom <- ifelse(is.null(input$map_zoom), 1, input$map_zoom)
  if(zoom >= zoomSeuil){
    rv$stations[
      rv$stations@coords[,1] > input$map_bounds$west &
        rv$stations@coords[,1] < input$map_bounds$east &
        rv$stations@coords[,2] > input$map_bounds$south &
        rv$stations@coords[,2] < input$map_bounds$north, ]
  }else{
    rv$stations[rep(F, dim(rv$stations)[1]),] # on ne sélectionne rien
  }
})