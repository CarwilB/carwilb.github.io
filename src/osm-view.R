# define the spatial extent to OpenStreetMap
lat1 <- -34.5; lat2 <- -33.5; lon1 <- 18; lon2 <- 19

library(OpenStreetMap)

# other 'type' options are "osm", "maptoolkit-topo", "bing", "stamen-toner",
# "stamen-watercolor", "esri", "esri-topo", "nps", "apple-iphoto", "skobbler";
# play around with 'zoom' to see what happens; 10 seems just right to me
#
# openmap asks for coordinates as upperLeft and lowerRight latlon pairs
bb <- bolivia.bb

sa_map <- openmap(c(bb$xmin, bb$ymax), c(bb$xmax, bb$ymin), zoom = 10,
                  type = "osm", mergeTiles = TRUE)

# reproject onto WGS84
sa_map2 <- openproj(sa_map)

sa_map2

# use instead of 'ggplot()'
sa_map2_plt <- OpenStreetMap::autoplot.OpenStreetMap(sa_map2) + 
  annotate("text", label = "Atlantic\nOcean", 
           x = 18.2, y = -33.8, size = 5.0, angle = -60, colour = "navy") +
  xlab("Longitude (°E)") + ylab("Latitude (°S)")
sa_map2_plt

## 

# load the location of the study sites
load("data/cape_point_sites.RData")

# define the spatial extent to OpenStreetMap
lat1 <- -34.5; lat2 <- -33.5; lon1 <- 18; lon2 <- 19

library(OpenStreetMap)

# other 'type' options are "osm", "maptoolkit-topo", "bing", "stamen-toner",
# "stamen-watercolor", "esri", "esri-topo", "nps", "apple-iphoto", "skobbler";
# play around with 'zoom' to see what happens; 10 seems just right to me
sa_map <- openmap(c(lat2, lon1), c(lat1, lon2), zoom = 10,
                  type = "osm", mergeTiles = TRUE)

# reproject onto WGS84
sa_map2 <- openproj(sa_map)

# use instead of 'ggplot()'
sa_map2_plt <- OpenStreetMap::autoplot.OpenStreetMap(sa_map2) + 
  annotate("text", label = "Atlantic\nOcean", 
           x = 18.2, y = -33.8, size = 5.0, angle = -60, colour = "navy") +
  xlab("Longitude (°E)") + ylab("Latitude (°S)")
sa_map2_plt
