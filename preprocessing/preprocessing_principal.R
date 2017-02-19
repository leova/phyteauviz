library(dplyr)
library(tidyr)
library(sp)
library(rgdal)
library(rgeos)
library(reshape2)

chemin_preprocessing <- '<chemin vers le dossier preprocessing>'

#### an ####
source(file.path(chemin_preprocessing, "preprocessing_an.R"))
summary(an)
# an = dataframe avec pour chaque pesticide mesuré en station,
# - la concentration moyenne 
# - le nombre d'analyses réalisées
# - le nombre d'analyses quantifiées

#### pest ####
# data.frame avec pour chaque pesticide
# - nom, norme, famille, fonction, statut, metabolite (données provenants de pesticides.csv)
# - moyenne nationale (calculée à partir de an)
# - KOC, DT50, DJA (importées de SIRIS)
source(file.path(chemin_preprocessing, "preprocessing_pesticides.R"))
summary(pest)


#### stations ####
# SpatialPointsDataFrame avec
# - code station, commune
# - masse d'eau, profondeur prélèvement
# - concentration moyenne totale annuelle
# - nombre annuel de prélévements
source(file.path(chemin_preprocessing, 'preprocessing_station_spatial.R'))

#### eau et eau_union #### 
# faire tourner le script preprocessing_masses_eau.R pas à pas
# les étapes de simplification des polygones sont à réaliser avec la librairie GDAL (ogr2ogr)

# - eau -> pour tracé du profil
# chaque masse d'eau est un multipolygone (1 niveau de la masse d'eau = 1(ou +) polygone(s))
# - eauUnion - > pour affichage sur la carte de l'emprise de chaque masse d'eau
# pour chaque masse d'eau, les multipolygones contigues sont fusionnés

rm(list = ls()[!grepl("^an$|^pest$|^stations$|^eau", ls())])

#### CREATION du RData ####
save(list = ls(), file = file.path('phyteauviz/data', "data_phyteauviz.RData"))