##### LIBRAIRIES #####

library(shiny)
library(shinyjs)
library(leaflet)
library(sp)
library(dplyr)
library(tidyr)
library(rgdal)
library(ggplot2)
library(reshape2)
library(RColorBrewer)

##### DONNEES #####

#### Stations (spatial) ####
# stations <- read.csv(file = 'data/stations.csv', sep = ';', dec = ',', encoding = 'latin1')
stations <- readOGR(dsn = 'data/stations.sqlite')
### Mise en forme d'un tableau avec le nombre de prélèvements par an pour chaque station
# cette étape est réalisée ici et non pas dans preprocessing_station carles nested tableaux ne sont pas supportés par sqlite
stations@data <- stations@data %>% nest(-c(cd_station, nom_com, num_dep, profondeur_maxi_point, 
                                 cd_me_v2, cd_me_niv1_surf, moy2007, moy2008, moy2009, moy2010, moy2011, moy2012, moy2013, moy2014,
                                 selection, index))
stations@data <- stations@data %>% rename( nbprel = data ) %>% mutate(selection = F)
stations@data$nbprel <- lapply(stations@data$nbprel, function(x) melt(x, measure.vars = paste0("prel", 2007:2014)))

#### Masses d'eau (spatial) ####
# - eau -> pour tracé du profil
# chaque masse d'eau est un multipolygone (1 niveau de la masse d'eau = 1(ou +) polygone(s))
# - eauUnion - > pour affichage sur la carte de l'emprise de chaque masse d'eau
# pour chaque masse d'eau, les multipolygones contigues sont fusionnés
eau <- readOGR(dsn = 'data/masses_eau_simplifiees.sqlite')
eauUnion <- readOGR(dsn = 'data/masses_eau_union_s001.sqlite')

#### Analyses ####
an <- read.csv("data/an.csv")

#### Pesticides ####
pest <- read.csv("data/pesticidesToxMob.csv")