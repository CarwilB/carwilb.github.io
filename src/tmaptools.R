install.packages("tmaptools")
install.packages("tmap")

library(tmaptools)
library(tmap)

bolivia.bb <- bb (x="Bolivia")
villatunari <- geocode_OSM(q="Villa Tunari, Cochabamba, Bolivia")

de %>% unite("location", address:department, sep=", ", na.rm=TRUE, remove=FALSE) %>% 
       select(event_title, location) %>%
       unique()

huatajata <- geocode_OSM(q="Huatajata, Omasuyos, La Paz", geometry = "point")
huatajata

de.dated <- de %>%
  mutate(
    date = (paste(year, month, day, sep="-") 
            %>% ymd() %>% as.Date())) %>% 
  mutate(date_name = format(date, format="%B %d")) %>%
  mutate(year = NULL, month = NULL, day=NULL) %>%
  relocate(protest_domain, event_title, date)

de.municipality <- de.dated %>% 
  unite("location", municipality:department, sep=", ", 
        na.rm=TRUE, remove=FALSE) %>% select(event_title, date, location)
de.municipality.dist <- de.municipality %>% arrange(location) %>% distinct(location)

municipalities <- str_unique(de.municipality$location)
municipalities_df <- data.frame(municipality = municipalities, stringsAsFactors = FALSE)

muni5 <- head(municipalities_df, 5)

nominatim_loc_geo <- geocode_OSM(muni5$municipality,
                                 details = FALSE, as.data.frame = TRUE)
