# readOGR has been deprecated and must be replaced by new code…
# Existing import code
bolivia_muni_map <- readOGR(
  dsn = paste0(here::here("maps","bol_adm_gb2014_shp"),"/"),
  layer = "bol_admbnda_adm3_gov_2020514",
  verbose = FALSE
)

# One option —— Tested successfully and chosen
library(sf)

bolivia_muni_map_3 <- st_read(here::here("maps","bol_adm_gb2014_shp"),
                              layer = "bol_admbnda_adm3_gov_2020514"
                              )

# Code below this line tests whether everything works okay downstream
#
# This has a minor change from prior code that removes "$data" before
# the double brackets
all_municipalities <- data.frame(bolivia_muni_map_3[["ADM3_ES"]], 
#                                      bolivia_muni_map_3[["ADM2_ES"]], 
                                      bolivia_muni_map_3[["ADM1_ES"]])

all_municipalities_full <- data.frame(bolivia_muni_map_3[["ADM3_ES"]], 
                                      bolivia_muni_map_3[["ADM2_ES"]], 
                                      bolivia_muni_map_3[["ADM1_ES"]])
colnames(all_municipalities_full)[1] ="municipality"
colnames(all_municipalities_full)[2] ="province"
colnames(all_municipalities_full)[3] ="department"

# Another option —— Not yet tested successfully
library(terra)

bolivia_muni_map_2 <- vect(
  x = paste0(here::here("maps","bol_adm_gb2014_shp"),"/"),
  layer = "bol_admbnda_adm3_gov_2020514"
)
