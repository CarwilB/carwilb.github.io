library(leaflet)
library(here)
library(sf)
library(ggplot2)

bolivia_muni_map <- st_read(here::here("maps","bol_adm_gb2014_shp"),
                            layer = "bol_admbnda_adm3_gov_2020514"
)
bmm <- bolivia_muni_map

# Metrics for the complexity of the resulting map are given by:
print(object.size(bolivia_muni_map), units = "auto")

ggplot() +
  geom_sf(data=bmm) 

# Next step: work in this script to simplify the shapefile as described at…
# Issue https://github.com/UltimateConsequences/ultimate-consequences/issues/139