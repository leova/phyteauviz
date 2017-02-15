# Creation d'une couche vecteur SQLite des stations

library(dplyr)
library(tidyr)
library(sp)
library(rgdal)

# import stations
stations <- read.csv('<chemin vers stations.csv>', 
                     sep = ';', fileEncoding = 'latin1', dec = ',') %>% 
  filter(X_FICT_L93 != 0) %>% 
  select(X_FICT_L93, Y_FICT_L93, CD_STATION, NOM_COM, NUM_DEP, PROFONDEUR_MAXI_POINT, CD_ME_v2, CD_ME_niv1_surf)

# "123.45" -> 123.45
stations$PROFONDEUR_MAXI_POINT <- stations$PROFONDEUR_MAXI_POINT %>% as.character() %>% as.numeric()

# import concentrations totales annuelles moyennes par station
p07 <- read.csv(file = '<chemin vers moy_tot_quantif_2007.csv>', sep=';', dec = ',', fileEncoding = 'latin1')
p08 <- read.csv(file = '<chemin vers moy_tot_quantif_2008.csv>', sep=';', dec = ',', fileEncoding = 'latin1')
p09 <- read.csv(file = '<chemin vers moy_tot_quantif_2009.csv>', sep=';', dec = ',', fileEncoding = 'latin1')
p10 <- read.csv(file = '<chemin vers moy_tot_quantif_2010.csv>', sep=';', dec = ',', fileEncoding = 'latin1')
p11 <- read.csv(file = '<chemin vers moy_tot_quantif_2011.csv>', sep=';', dec = ',', fileEncoding = 'latin1')
p12 <- read.csv(file = '<chemin vers moy_tot_quantif_2012.csv>', sep=';', dec = ',', fileEncoding = 'latin1')
p13 <- read.csv(file = '<chemin vers moy_tot_quantif_2013.csv>', sep=';', dec = ',', fileEncoding = 'latin1')
p14 <- read.csv(file = '<chemin vers moy_tot_quantif_2014.csv>', sep=';', dec = ',', fileEncoding = 'latin1')

# ajout des concentrations totales moyennes annuellesc omme nouvelles colonnes de "stations"
stations <- left_join(stations, p07 %>% select(CD_STATION, MOYPTOT, NBPREL) %>% rename("moy2007" = MOYPTOT, "prel2007" = NBPREL))
stations <- left_join(stations, p08 %>% select(CD_STATION, MOYPTOT, NBPREL) %>% rename("moy2008" = MOYPTOT, "prel2008" = NBPREL))
stations <- left_join(stations, p09 %>% select(CD_STATION, MOYPTOT, NBPREL) %>% rename("moy2009" = MOYPTOT, "prel2009" = NBPREL))
stations <- left_join(stations, p10 %>% select(CD_STATION, MOYPTOT, NBPREL) %>% rename("moy2010" = MOYPTOT, "prel2010" = NBPREL))
stations <- left_join(stations, p11 %>% select(CD_STATION, MOYPTOT, NBPREL) %>% rename("moy2011" = MOYPTOT, "prel2011" = NBPREL))
stations <- left_join(stations, p12 %>% select(CD_STATION, MOYPTOT, NBPREL) %>% rename("moy2012" = MOYPTOT, "prel2012" = NBPREL))
stations <- left_join(stations, p13 %>% select(CD_STATION, MOYPTOT, NBPREL) %>% rename("moy2013" = MOYPTOT, "prel2013" = NBPREL))
stations <- left_join(stations, p14 %>% select(CD_STATION, MOYPTOT, NBPREL) %>% rename("moy2014" = MOYPTOT, "prel2014" = NBPREL))

## on enlève les stations qui n'ont jamais été analysées
# les 13000 stations, seulement 2391 ont des données d'analyse
# celles qui n'ont pas d'analyse sont exclues
stations <- stations %>% filter( CD_STATION %in% (
  # stations déjà analysées
  c(p07$CD_STATION %>% as.character, p08$CD_STATION %>% as.character, 
    p09$CD_STATION %>% as.character, p10$CD_STATION %>% as.character, 
    p11$CD_STATION %>% as.character, p12$CD_STATION %>% as.character, 
    p13$CD_STATION %>% as.character, p14$CD_STATION %>% as.character) %>%
    unique())
)

# Ajout témoin de sélection initialisé à F
stations$selection <- rep(F, dim(stations)[1])

# Ajout index
stations$index <- 1:dim(stations)[1]

# summary(stations)

# Conversion en objet SpatialPointsDataFrame
stations_sp <- SpatialPointsDataFrame(coords = stations %>% select(X_FICT_L93, Y_FICT_L93),
                                      data = stations %>% 
                                        select(-X_FICT_L93, -Y_FICT_L93)
)
# Définition de la projection en WGS84
stations_sp@proj4string <- CRS("+init=epsg:2154") # X_FICT_L93 et Y_FICT_L93 sont projetés en Lambert93
stations_sp <- spTransform(stations_sp, CRS("+init=epsg:4326"))   

# sauvegarde de la nouvelle couche
writeOGR(obj = stations_sp, 
         dsn = 'stations.sqlite', 
         layer = 'stations', driver = 'SQLite')
