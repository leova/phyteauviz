##### PARAMETRES ET METADONNEES #####

#### Couleurs Concentrations Carte ####
pal <- colorBin(palette = c("Green", "Yellow", "Red", "Black"),
                domain = c(0,300),
                bins = c(0,
                         0.01, #0.001 ug/l = limite supérieure de la classe "pas de pesticides"
                         0.25, #
                         0.5, # 0.5 ug/l (normeDCE)
                         5, # = limite inférieure de la classe "bcp bcp de pesticides"
                         300))



#### Couleurs selection carte ####

couleurMasseEau <- "#334364" # bleu foncé
# couleurStationSel <- "#FFF407" # jaune
# couleurStationSel <- "#63563c" # marron
# couleurStationSel <- "#8CC3ED"  # bleu clair


#### Graph "profil du sous-sol" ####
profilSol <- ggplot()  +
  # le ciel
  geom_polygon(data = data.frame(x=c(0,0,1,1),
                                 y=c(0,-2,-2,0),
                                 id=rep("ciel",4)),
               aes(x = x, y = y, group = id), fill="lightblue", alpha=0.5) +
  # la station
  geom_polygon(data = data.frame(x=c(0.5-0.1, 0.5-0.1, 0.5, 0.5+0.1, 0.5+0.1),
                                 y=c(0, -0.7, -1.2, -0.7, 0),
                                 id=rep("station",5)),
               aes(x = x, y = y, group = id), fill="black", alpha=0.6) +
  # le sous-sol
  geom_polygon(data = data.frame(x=c(0,0,1,1),
                                 y=c(0,10.5,10.5,0),
                                 id=rep("sol",4)),
               aes(x = x, y = y, group = id), fill="#8D614C", alpha=0.5) +
  # la surface
  geom_hline(yintercept = 0, color = 'black', size = 0.5) +
  coord_cartesian(xlim=c(0.2,0.8)) +
  theme(panel.grid = element_blank(),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_text(color=couleurMasseEau, size = 10, face = "bold"),
        axis.text.x = element_blank(),
        axis.ticks = element_blank(),
        legend.position = "none")

#### Metadonnes "Fonctions des pesticides" ####

pest$CODE_FONCTION <- as.character(pest$CODE_FONCTION)
pest$CODE_FONCTION[pest$CODE_FONCTION == ""]  <- "X" # gestion des données manquantes
fonctionsPestDf <- data.frame(
  fonc = c("A",
           "F" ,
           "H",
           "I",
           "M",
           "Reg",
           "RepO",
           "Ro",
           "X"),
  labels = c("acaricide(s)",
             "fongicide(s)",
             "herbicide(s)",
             "insecticide(s)",
             "mollusticide(s)",
             "régulateur(s) de croissance(s)",
             "répulsif(s)",
             "rodenticide(s)",
             'donnée(s) "fonction" manquante(s)'),
  couleur = c(brewer.pal(8,"Set3")[2], brewer.pal(8,"Set2"))
)
couleursFoncPest <- as.character(fonctionsPestDf$couleur) ; names(couleursFoncPest) <- fonctionsPestDf$fonc
scaleFoncPest <- scale_fill_manual(name = "foncPest", values = couleursFoncPest)

#### Metadonnes "Statuts des pesticides" ####

pest$STATUT <- as.character(pest$STATUT)
pest$STATUT[pest$STATUT == "" | pest$STATUT == "SO"]  <- "NoData" # gestion des données manquantes
statutPestDF <- data.frame(
  statut = c("PA",
             "PNA",
             # "SO",
             "NoData"),
  labels = c("pesticide(s) autorisé(s)",
             "pesticide(s) non-autorisé(s)",
             # '"SO"',
             'donnée(s) "statut" manquante(s)'),
  # couleur = brewer.pal(9,"Set1")[c(3,1,7,9)]
  couleur = brewer.pal(12,"Set3")[c(7,4,
                                    # 3,
                                    9)]
)
couleursStatutPest <- as.character(statutPestDF$couleur) ; names(couleursStatutPest) <- statutPestDF$statut
scaleStatutPest <- scale_fill_manual(name = "statutPest", values = couleursStatutPest)

#### Metadonnées pour filtres ####
typeAnDf <- data.frame(
  typeAn = c("QUANTIFINFDCE_STATION",
             "QUANTIFSUPDCE_STATION",
             "DETECINFDCE_STATION",
             "DETECSUPDCE_STATION"),
  labels = c("pesticide(s) quantifié(s) au moins une fois\n(concentration mesurée inférieure à la norme DCE)",
             "pesticide(s) quantifié(s) au moins une fois\n(concentration mesurée supérieure à la norme DCE)",
             "pesticide(s) détecté(s) non-quantifié(s)\n(concentration estimée inférieure à la norme DCE)",
             "pesticide(s) détecté(s) non-quantifié(s)\n(concentration estimée supérieure à la norme DCE)"),
  couleur = brewer.pal(8,"Paired")[5:8]
)
couleursTypeAn <- as.character(typeAnDf$couleur) ; names(couleursTypeAn) <- typeAnDf$typeAn
scaleTypeAn <- scale_fill_manual(name = "typeAn", values = couleursTypeAn)


#### Graph de sélection des pesticides et graph evolution concentration ####

# parametres des indicateurs pour rendu graph pest
paramPestFilt <- list(
  table = read.csv(header = TRUE, strip.white = T,
                   text = 'indic,indicateur,axeTrans,naVal
                   MOY_STATION,"Concentration: moyenne (µg/L)",log,NA
                   EVOL_STATION,"Concentration: évolution (µg/L/an)",identity,0
                   DIFF_NAT,"Concentration: différence à la moyenne nationale (µg/L)",identity,NA
                   DJA,"Toxicité chronique: DJA (mg/kg/jour)",log,999
                   KOC,"Mobilité: KOC (L/g)",log,1e10
                   DT50Champs,"Dégradabilité: DT50 champs (jour)",log,9999', na.string = "NA"),
  zones = list(
    MOY_STATION = list(
      limitesdf = data.frame(limites = 0.1),
      labels = c("< norme DCE", "> norme DCE")
    ),
    EVOL_STATION = list(
      limitesdf = data.frame( limites = c(-0.005, 0.005) ),
      labels = c("< -0.005", "stable", "> +0.005")
    ),
    DIFF_NAT = list(
      limitesdf = data.frame( limites = c(-0.02, 0.02) ),
      labels = c("< -0.02", "=", "> 0.02")
    ),
    DJA = list(
      limitesdf = data.frame( limites = c(0.02, 400) ), # DJAmax = 9, NA = 999
      labels = c("< 0.02","> 0.02", "donnée\nmanquante")
    ),
    KOC = list(
      limitesdf = data.frame( limites = c(75, 500, 1e8) ), # NA = 1e10, KOCmax = 10 240 000
      labels = c("mobile", "modérément\nmobile", "peu\nmobile", "donnée\nmanquante")
    ),
    DT50Champs = list(
      limitesdf = data.frame( limites = c(100, 365, 6000) ), # NA = 9999, DT50mx = 2000
      labels = c('dégradable', 'modérément\ndégradable', 'peu\ndégradable', 'donnée\nmanquante')
    )
  )
  )
choix_selectize <- paramPestFilt$table$indic %>% as.character()
names(choix_selectize) <- paramPestFilt$table$indicateur %>% as.character()

# nombre initial de pesticides sélectionnés
nSelPest <- 4
# Nombre max de pesticides visualisables
nMaxPest <- 10
pestSelValeurs <- paste("pest", 1:nMaxPest)
# échelle de couleur
couleursPest <- c(grey(0.8),"#958ece","#da5b3a","#83dca9", "#6f9350",
                  "#59b3c3","#d5638d","#84d64f","#d3c250","#b65bd7","#c38d61")
names(couleursPest) <- c("pas sélectionné", pestSelValeurs)
echelleCoulPest <- scale_colour_manual(name = "Pesticide(s) sélectionné(s)",values = couleursPest)
# rayon d'un point non-sélectionné
pestNSelRayon <- 3
# rayon d'un point sélectionné
pestSelRayon <- 5

### thèmes graph pesticide et graph analyses
themeGraphPest <- theme(panel.background = element_rect(fill = grey(0.4)),
                        plot.background = element_rect(fill = "transparent",colour = NA),
                        axis.ticks = element_blank(),
                        axis.text = element_text(size = unit(10,'pt')),
                        axis.text.y = element_text(angle = 0, hjust = 1, vjust = 0.5),
                        panel.grid.minor = element_blank(),
                        panel.grid.major = element_blank(),
                        panel.spacing = unit(c(0,0,0,0), "pt"),
                        legend.position = "none")
themeGraphAn <- theme(panel.background = element_rect(fill = grey(0.4)),
                      plot.background = element_rect(fill = "transparent",colour = NA),
                      panel.grid.minor.x = element_blank(),
                      panel.grid.minor.y = element_line(size=0.05),
                      panel.grid.major = element_line(size=0.1),
                      legend.key=element_rect(fill=grey(0.4)),
                      legend.background = element_rect(fill= "transparent", colour = NA),
                      axis.title.x = element_blank(),
                      legend.position = "top")


#### Schémas pédagogiques ####
schema <- data.frame(indice = 1:3,
                     titre = c("Surveiller les masses d'eau?",
                               "Fonctionnement des masses d'eau?",
                               "Pesticides et masses d'eau?"))

