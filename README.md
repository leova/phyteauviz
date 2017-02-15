# Phyt'eau viz

Application de visualisation de la concentration en pesticides des eaux sous-terraines réalisée dans le cadre du [concours de data-visualisation sur les pesticides dans les eaux souterraines](http://www.developpement-durable.gouv.fr/concours-data-visualisation-sur-pesticides-dans-eaux-souterraines-0) organisé par le [Ministère de l'environnement, de l'énergie et de la mer](http://www.developpement-durable.gouv.fr).

## Auteurs

*Développement*: [Léo V.](https://github.com/leova)

*Schémas et bulles d'information* : Xavier Peyrard

## Code et licence
Le code source est dispnible sur [github](https://github.com/leova/phyteauviz/) sous licence [GNU GENERAL PUBLIC LICENSE v3.0](https://github.com/leova/phyteauviz/blob/master/LICENSE)
	
## Source des données

Les données liées aux stations de suivi et aux masses d'eaux sont publiques et fournies à travers le [Système d'Information sur l'Eau](http://www.eaufrance.fr) (SIE).

La structure des données du SIE sont gérées par le [Service d’administration nationale des données et référentiels sur l’eau (Sandre)](http://www.sandre.eaufrance.fr), lui-même piloté par l'[Office national de l'eau et des milieux aquatiques (Onema)](http://www.onema.fr).

Plus spécifiquement, les données liées à la qualité des masses d'eaux souterraines sont gérées, au sein du SIE, par la [banque nationale d’Accès aux Données sur les Eaux Souterraines (ADES)](http://www.ades.eaufrance.fr)
Les [données comportementales des pesticides (données Koc, DT50 champs et DJA)](http://www.ineris.fr/siris-pesticides/siris_base_xls/siris_2012.xls) sont issues de la base de données du [Système d'Intégration des Risques par Interaction des Scores pour les Pesticides](http://www.ineris.fr/siris-pesticides/accueil), géré par l'[Institut National de l'Environnement Industriel et des Risques (INERIS)](http://www.ineris.fr/).

# Documentation d'installation

## Installation des librairies

* librairie [GDAL](http://www.gdal.org/index.html)
* librairies R:

```
install.packages('shiny')
install.packages('shinyjs')
install.packages('leaflet')
install.packages('sp')
install.packages('dplyr')
install.packages('tidyr')
install.packages('rgdal')
install.packages('ggplot2')
install.packages('reshape2')
install.packages('RColorBrewer')
```

## Téléchargement des données

* Données du concours [(lien)](http://www.donnees.statistiques.developpement-durable.gouv.fr/dataviz_pesticides/)
* Données comportementales des pesticides [(lien)](http://www.ineris.fr/siris-pesticides/siris_base_xls/siris_2012.xls)

## Pré-traîtement des données

1. générer `an.csv` à partir du script `preprocessing/preprocessing_an.R`
2. générer `pesticidesToxMob.csv` à partir du script `preprocessing/preprocessing_pesticides.R`
3. générer `stations.sqlite` à partir du script `preprocessing/preprocessing_station_spatial.R`
4. générer `masses_eau_simplifiees.sqlite` et `masses_eau_union.sqlite` à partir du script `preprocessing/preprocessing_masses_eau` (au préalable, générer `PolygMasseDEauSouterraineS400.shp` à partir d'`ogr2ogr`: `ogr2ogr -simplify 400 PolygMasseDEauSouterraineS400.shp PolygMasseDEauSouterraine.shp`)

NB `an.csv`, `pesticidesToxMob.csv`, `stations.sqlite`, `masses_eau_simplifiees.sqlite` et `masses_eau_union.sqlite` doivent être placés dans `app/data/`

## Lancement de l'application en local

`shiny::runApp("app/")`

## Déploiement sur un serveur

`rsconnect::deployApp("app/", server = "<mon server>")`

avec `<mon serveur>` = [shinyapp.io](https://www.shinyapps.io/) ou un [shiny server](https://github.com/rstudio/shiny-server/blob/master/README.md)