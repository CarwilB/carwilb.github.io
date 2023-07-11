# script from "Having bit of party with Material Colour Palette"
# by Chisato
# https://chichacha.netlify.app/2018/12/09/having-bit-of-party-with-material-colour-palette/

## Load up packages we'll use
# library(tidyverse)
# library(imager)
# library(patchwork)
# library(here)
# 
# fpath <- here::here("src", "material-colors-thumb.png")
# im <- load.image(fpath)
# #plot(im)
# 
# ## Convert Image to Data Frame with HSV value
# im_hsv <-im %>% RGBtoHSV() %>%
#   as.data.frame(wide="c") %>%
#   rename(h=c.1, s=c.2, v=c.3)
# 
# ## Convert Image to Data Frame with RGB value
# im_rgb <- im %>% 
#   as.data.frame(wide="c") %>%
#   rename(red=c.1,green=c.2,blue=c.3) %>%
#   mutate(hexvalue = rgb(red,green,blue)) ## you can create hexvalue using red, green blue value!
# 
# ## Might as well conver to grayscale, and get luminance. 
# ## I;ll use luminance value to decide if I'll put black text vs white text later.
# im_grayscale <- im %>% grayscale() %>%
#   as.data.frame() %>%
#   rename(luminance=value)
# 
# ## I want to grab pixel from about middle of each cell
# mat_color <- im_rgb %>%
#   filter(x %in% as.integer(round(seq(1,19)*(400/19))-10) &
#            y %in% as.integer(round(seq(1,11)*(225/11))-10) & y>10) %>%
#   left_join(im_hsv) %>%
#   left_join(im_grayscale) %>%
#   mutate_at(c("x","y"), dense_rank) %>%
#   arrange(x,y) 
# 
# 
# col_group <- c("red","pink","purple","deep purple","indigo","blue","light blue","cyan","teal","green","light green","lime","yellow","amber","orange","deep orange","brown","grey","blue grey")
# 
# ## Adding extra info to the table 
# mat_color <- mat_color %>% 
#   mutate(hue_group=factor(x, labels=col_group, ordered=T),
#          shade = factor(y, labels=c(50,seq(100,900, by=100)), ordered=T))
# 
# mat_color <- mat_color %>%
#   mutate(name=paste0(hue_group,"-",shade))
# 
# ## I could also save this as csv file too... :) 
# mat_color %>% write_csv(here::here("data","MaterialColour.csv"))

#  No need to run anything above this line again.
## ===========================================================
## load & use
mat_color <- read_csv(here::here("data","MaterialColour.csv"))

mat_color_hex <- mat_color$hexvalue
names(mat_color_hex) <- mat_color$name

mat_color_hex['green-100']

# protest_domain.grouped - a factor ordering
# protest_domain.colors - an associated color assignment
#
protest_domain.grouped <- c( 
  "Gas Wars",                         # Economic
  "Economic policies",
  "Labor",
  "Education",
  "Mining",
  "Coca",                             # Rural
  "Peasant",
  "Rural Land",
  "Rural Land, Partisan Politics",
  "Ethno-ecological",
  "Drug trade",                       # Criminalized
  "Contraband",
  "Local development",                # Local
  "Municipal governance",
  "Partisan Politics",                # (solo)
  "Disabled",                         # (solo)
  "Guerrilla",                        # Armed actors
  "Paramilitary",
  "Urban land",
  "Unknown")                       # (solo)

protest_domain.colors <- c( 
  "Gas Wars" = mat_color_hex[['blue-900']],
  "Economic policies" = mat_color_hex[['blue-700']],
  "Labor" = mat_color_hex[['blue-500']],
  "Education" = mat_color_hex[['blue-200']],
  "Coca" = mat_color_hex[['green-900']],
  "Peasant" = mat_color_hex[['green-600']],
  "Rural Land" = mat_color_hex[['green-300']],
  "Rural Land, Partisan Politics" = mat_color_hex[['green-200']],
  "Ethno-ecological" = mat_color_hex[['light green-100']],
  "Drug trade" = mat_color_hex[['lime-700']],
  "Contraband" = mat_color_hex[['lime-400']],
  "Mining" = mat_color_hex[['red-700']],
  "Local development" = mat_color_hex[['deep purple-700']],
  "Municipal governance" = mat_color_hex[['deep purple-400']],
  "Partisan Politics" = mat_color_hex[['pink-300']],
  "Disabled" = mat_color_hex[['blue grey-600']],
  "Guerrilla" = mat_color_hex[['brown-800']],
  "Paramilitary" = mat_color_hex[['brown-400']],
  "Urban land" = mat_color_hex[['yellow-500']],
  "Unknown" = mat_color_hex[['grey-300']]
)


