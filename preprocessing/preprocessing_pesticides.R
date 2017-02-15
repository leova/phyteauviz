library(dplyr)

pest <- read.csv('<chemin vers pesticides.csv>', sep = ";", dec = ",", encoding = 'latin1')
an <- read.csv('<chemin vers an.csv>',
               encoding = 'latin1', dec='.')
siris <- read.csv('<chemin vers siris_2012_curation.csv>', sep = ',', dec = ',', na.strings = "")

### pesticides.csv: Enlever doublons (CD_PARAMETRE)
pest %>% filter(duplicated(CD_PARAMETRE))
pest %>% filter(CD_PARAMETRE %in% c(1141, 1208, 1177))
## 1141: 2,4-D
# on enlève 2,4-D methyl ester, on garde 2,4-D
pest <- pest %>% filter(LB_PARAMETRE != "2,4-D methyl ester")
## 1208: Isoproturon
# Isoproturon desmethyl est un métabolite de l'Isoproturon mais a le même CD_PARAMETRE
# -> Isoproturon desmethyl = 12081
pest$CD_PARAMETRE[pest$LB_PARAMETRE == "Isoproturon desmethyl"] <- 12081
## 1177: Diuron/ Diuron desmethyl
# Le durion desmethy est certainement un metabolite -> 11771
pest$CD_PARAMETRE[pest$LB_PARAMETRE == "Diuron desmethyl"] <- 11771

#### SIRIS
# garder que les colonnes de siris qui sont significatives
# et les codes CAS non-dupliqués
siris <- siris %>% 
  rename(NOM_SIRIS = nom.SIRIS.2012, DT50Champs = DT50.champ..jours., KOC = Koc..mL.g.1., DJA = DJA..mg.kg.1.j.1.) %>% 
  select(CAS.SIRIS.2012, NOM_SIRIS, KOC, DT50Champs, DJA) %>%
  filter(!duplicated(CAS.SIRIS.2012))

#### jointure pesticides.csv et siris_2012.csv
pestSiris <- left_join(pest, 
                        siris,
                        by = c("CODE_CAS" = "CAS.SIRIS.2012")) ; dim(pestSiris)

#### Ajout de moyenne nationale pesticides
anMoyNat <- an %>% group_by(CD_PARAMETRE) %>% 
  summarise(MOY_NAT = mean(MA_MOY)) ; dim(anMoyNat)

# right_join: On ne garde que les pesticides effectiffement analysés
pestSirisMoyNat <- right_join(pestSiris, anMoyNat, by=c("CD_PARAMETRE" = "CD_PARAMETRE")) ; dim(pestSirisMoyNat)

#### On attribue des valeurs arbitraires aux données manquantes 
## afin que tous les pesticides soient représentés sur graph pest

# "Toxicité: DJA" = 999,
pestSirisMoyNat$DJA[is.na(pestSirisMoyNat$DJA)] <- 999
# "Mobilité: KOC" = 1e10,
pestSirisMoyNat$KOC[is.na(pestSirisMoyNat$KOC)] <- 1e10
# "Mobilité: DT50 champs" = 9999
pestSirisMoyNat$DT50Champs[is.na(pestSirisMoyNat$DT50Champs)] <- 9999

write.csv(pestSirisMoyNat, "pesticidesToxMob.csv", row.names = F)
