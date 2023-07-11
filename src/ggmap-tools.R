# Packages
install.packages("ggmap")

# Registration for Google API (do this once per session)
#
# This key is for internal project use only!
library(ggmap)

register_google(key = "AIzaSyDDwG1E0UXjQqduHQ5jf1IQ5BuQfi3a3HI")

loc.villatunari <- "Villa Tunari, Cochabamba, Bolivia"


# geocode described here: https://www.rdocumentation.org/packages/ggmap/versions/3.0.1/topics/geocode
gc.villatunari <- geocode(
  loc.villatunari,
  output = "latlon",
  urlonly = FALSE,
  override_limit = FALSE,
)

de.loc <- de %>% unite("location", address:department, sep=", ",
                       na.rm=TRUE, remove=FALSE) %>% select(event_title, location)

# de.located <- de.loc %>% mutate

de.dated <- de %>%
  mutate(
    date = (paste(year, month, day, sep="-") 
            %>% ymd() %>% as.Date())) %>% 
  mutate(date_name = format(date, format="%B %d")) %>%
  mutate(year = NULL, month = NULL, day=NULL) %>%
  relocate(event_title, date)

de.municipality <- de.dated %>% 
                      mutate(municipality = str_c(municipality, "Municipality", sep=" ")) %>%
                      unite("location", municipality:department, sep=", ", 
                                na.rm=TRUE, remove=FALSE) %>% select(event_title, date, location)
de.municipality.dist <- de.municipality %>% arrange(location) %>% distinct(location)

municipalities <- str_unique(de.municipality$location)
municipalities_df <- data.frame(municipality = municipalities, stringsAsFactors = FALSE)
# locations_df <- mutate_geocode(municipalities_df, location = municipality, region = "bo")

# saveRDS(locations_df, file = "data/municipalities-table-2.RDS", compress = FALSE)
locations_df <- readRDS(file="data/municipalities-table-gg.RDS")

de.municipality <- dplyr::rename(de.municipality, municipality = location)
de.municipality.located <- left_join(de.municipality, locations_df)

# Full address locations
#
# We'll filter out cases where there's no additional information here

de.address <- de %>% filter((!is.na(address))&(!is.na(community))) %>%
                     mutate(community=NULL) %>%
                           unite("location", address:department, sep=", ", 
                                na.rm=TRUE, remove=FALSE) %>% select(event_title, location)

de.address.dist <- de.address %>% arrange(location) %>% distinct()
flextable(de.address.dist)

addresses <- str_unique(de.address$location)
addresses_df <- data.frame(address = addresses, stringsAsFactors = FALSE)
locations_a_df <- mutate_geocode(addresses_df, location = address)

saveRDS(locations_a_df, file = "data/addresses-table.RDS", compress = FALSE)

###
# df <- data.frame(
#         address = c("1600 Pennsylvania Avenue, Washington DC", "", "houston texas"),
#         stringsAsFactors = FALSE
#         )
# mutate_geocode(df, address)

# install.packages("mapview")

library(sf)
library(mapview)

locations <- as_tibble(locations_df)
locations <- locations %>% filter(!is.na(lat) & !is.na(lon))
locations_sf <- st_as_sf(locations, coords = c("lon", "lat"), crs = 4326)
mapview(locations_sf)

locations <- as_tibble(de.municipality.located)
locations <- locations %>% filter(!is.na(lat) & !is.na(lon))
locations_sf <- st_as_sf(locations, coords = c("lon", "lat"), crs = 4326)
mapview(locations_sf)


locations_a <- as_tibble(locations_a_df)
locations_a <- locations_a %>% filter(!is.na(lat) & !is.na(lon))
locations_a_sf <- st_as_sf(locations_a, coords = c("lon", "lat"), crs = 4326)
mapview(locations_a_sf)
