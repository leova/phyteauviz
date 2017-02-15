##### REACTIVE VALUES #####
rv <- reactiveValues()

## rendre "stations" reactif 
# stations (spatial) = 
# - concentration moyennes cumulées par station et par an
# - temoin de sélection (colonne sélection)
rv$stations <- stations

# indice pour affichage schémas
rv$schemak <- 1