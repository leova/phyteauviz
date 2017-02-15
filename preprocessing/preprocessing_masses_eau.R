library(rgdal)
library(rgeos)
library(plyr)

##
# Preprocessing de PolygMasseDEauSouterraine.shp
# Creation de 2 couches:
#   1/ "masses_eau_simplifiees.sqlite"
#     - Simplification de la géométrie des polygones
#     - Réduction du nombre de colonnes dans la table attributaire
#     - Conversion des coordonnées en WGS84
#   2/ "masses_eau_simplifiees_union.sqlite"
#     - Conversion des coordonnées en WGS84
#     - Union des mutipolygones de chaque masse d'eau
#     - Simplification de la géométrie des polygones
##

##### masses_eau_simplifiees.sqlite #####

#### Simplification de la géométrie des polygones (en dehors de R) ####
# PolygMasseDEauSouterraine.shp est lourd 173Mo et la précision des polygones n'est pas nécessaire pour l'application

# comme rgeos::gSimplify() ne gère pas un volume important de données,
# il est préférable d'utiliser directement OGR en ligne de commande
# $ ogr2ogr -simplify 400 PolygMasseDEauSouterraineS400.shp PolygMasseDEauSouterraine.shp

### import
setwd('~/DataScience/Data/France/BDD_concours_Pesticides_20161229/Polygone MasseDEauSouterraine_VEDL2013_FXX-shp_simplifie/')
eau <- readOGR(dsn = 'PolygMasseDEauSouterraineS400.shp', layer = 'PolygMasseDEauSouterraineS400', encoding = "utf8")

#### CRS ####
eau <- spTransform(eau, CRS("+init=epsg:4326"))

#### Réduction du nombre de colonnes de la table attributaire #####
# names(eau[, c(1,2,4,5,16)])
eau <- eau[, c(1,2,4,5,16)]

#### natures de l'aquifère de la masse d'eau
# renommer codes
eau$TypeMasseD <- revalue(eau$TypeMasseD, c("A" = "Alluvial", 
               "DS" = "Dominante sédimentaire",
               "EV" = "Edifice Volcanique", 
               "IP" = "Intensément Plissée (montagnes)", 
               "S" = "Socle", 
               "IL" = "Imperméable localement"))


### export
setwd('~/DataScience/Concours/Pesticides_Eau/appPesticides/data/')
writeOGR(obj = eau, 
         dsn = 'masses_eau_simplifiees.sqlite', 
         layer = 'masses_eau_simplifiees', driver = 'SQLite')

##### masses_eau_simplifiees_union.sqlite #####

## Import
setwd('~/DataScience/Data/France/BDD_concours_Pesticides_20161229/Polygone MasseDEauSouterraine_VEDL2013_FXX-shp/')
eau <- readOGR(dsn = 'PolygMasseDEauSouterraine.shp', layer = 'PolygMasseDEauSouterraine', encoding = "utf8")

#### CRS ####
eau <- spTransform(eau, CRS("+init=epsg:4326"))

#### Union ####
## Union des polygones d'une même masse d'eau
eau_union <- eau %>% gUnionCascaded(id = as.character(eau@data$CdMasseDEa))
eau_df <- eau@data %>% group_by(CdMasseDEa) %>% summarise() %>% as.data.frame()
rownames(eau_df) <- eau_df$CdMasseDEa
eau_union_df <- SpatialPolygonsDataFrame(eau_union, eau_df)

#### Simplification geom (hors de R) ####
# export tmp
setwd('/tmp')
writeOGR(obj = eau_union_df, 
         dsn = 'masses_eau_union.sqlite', 
         layer = 'masses_eau_union', driver = 'SQLite')

# $ cd /tmp
# $ ogr2ogr -simplify 400 masses_eau_union_S400.sqlite masses_eau_union.sqlite
