#### Moyennes_analyses_pesticides_dans_eaux_souterraines_HISTORIQUE

p07 <- read.csv(file = '<chemin vers ma_qp_fm_ttres_pesteso_2007.csv>', sep=';', dec = ',', fileEncoding = 'latin1') %>% mutate(ANNEE = '2007')
p08 <- read.csv(file = '<chemin vers ma_qp_fm_ttres_pesteso_2008.csv>', sep=';', dec = ',', fileEncoding = 'latin1') %>% mutate(ANNEE = '2008')
p09 <- read.csv(file = '<chemin vers ma_qp_fm_ttres_pesteso_2009.csv>', sep=';', dec = ',', fileEncoding = 'latin1') %>% mutate(ANNEE = '2009')
p10 <- read.csv(file = '<chemin vers ma_qp_fm_ttres_pesteso_2010.csv>', sep=';', dec = ',', fileEncoding = 'latin1') %>% mutate(ANNEE = '2010')
p11 <- read.csv(file = '<chemin vers ma_qp_fm_ttres_pesteso_2011.csv>', sep=';', dec = ',', fileEncoding = 'latin1') %>% mutate(ANNEE = '2011')
p12 <- read.csv(file = '<chemin vers ma_qp_fm_ttres_pesteso_2012.csv>', sep=';', dec = ',', fileEncoding = 'latin1') %>% mutate(ANNEE = '2012')
p13 <- read.csv(file = '<chemin vers ma_qp_fm_rcsrco_pesteso_2013.csv>', sep=';', dec = ',', fileEncoding = 'latin1') %>% mutate(ANNEE = '2013')
p14 <- read.csv(file = '<chemin vers ma_qp_fm_rcsrco_pesteso_2014.csv>', sep=';', dec = ',', fileEncoding = 'latin1') %>% mutate(ANNEE = '2014')

an <- rbind(p07, p08, p09, p10, p11, p12, p13, p14) ; summary(an)

write.csv(an %>% select(-NORME_DCE, -LB_PARAMETRE), 'an.csv', row.names = FALSE )