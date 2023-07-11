### Option 3: Pacman package manager is in install-packages.R
if (!require("pacman")) install.packages("pacman") #install pacman if it's not there

pacman::p_load(
  # This list of packages is a fork of the Epidemiologist R Handbook's list
  # https://epirhandbook.com/suggested-packages-1.html
  #
  # package install and management
  ################################
  pacman,   # package install/load
  devtools, # developer tools
  renv,     # managing versions of packages when working in collaborative groups
  remotes,  # install from github
  gitcreds,  # GitHub credentials tools
  usethis,  # enables remote management of github
  here,     # handle working directory and file location

  # General data management
  #########################
  tidyverse,    # includes many packages for tidy data wrangling and presentation
   # dplyr,      # data management
   # tidyr,      # data management
   # ggplot2,    # data visualization
   # stringr,    # work with strings and characters
   # forcats,    # work with factors 
   # lubridate,  # work with dates
   # purrr       # iteration and working with lists
  #  linelist,     # cleaning linelists
  naniar,       # assessing missing data
  skimr,         # characterizes the variables
  scales,       # useful for "percent()"
  english,      # convert numbers to words
  datawizard,   # multiple kinds of data wrangling
  stringdist,   # fuzzy string matching
  
  # statistics  
  ############
  janitor,      # tables and data cleaning
  arsenal,      # makes pretty summary tables
  flextable,    #p pretty tables that are PDF friendly
  #  gtsummary,    # making descriptive and statistical tables
  #  rstatix,      # quickly run statistical tests and summaries
  #  broom,        # tidy up results from regressions
  #  lmtest,       # likelihood-ratio tests
  #  easystats,
  # parameters, # alternative to tidy up results from regressions
  # see,        # alternative to visualise forest plots
  reactable,     # dynamic tables
  reactablefmtr, # customize format for reactable 
  V8,            # enables static versions of reactable
  treemapify,
  
  # plots - general
  #################
  # ggplot2,         # included in tidyverse
  ggfittext,
  ggthemes,
  ggtext,
  cowplot,          # combining plots  
  GGally,           # extra statistics for ggplot2
  # patchwork,      # combining plots (alternative)     
  RColorBrewer,     # color scales
  hrbrthemes,       # themes for waffle charts
  # ggnewscale,       # to add additional layers of color schemes
  webshot,           # enable flextable conversion to raster
  magick,            # enable flextable conversion to raster
  
  # plots - specific types
  ########################
  #  DiagrammeR,       # diagrams using DOT language
  #  incidence2,       # epidemic curves
  gghighlight,      # highlight a subset
  ggrepel,          # smart labels
  plotly,           # interactive graphics
  kableExtra,       # upgrade Kable formatting
   #  gganimate,        # animated graphics 
  ggalluvial,      # alluvial / Sankey plots
  kableExtra       # enhance table output
  
  
)

pacman::p_install_gh("yogevherz/plotme") # interfaces between tidyverse and plotly fromats

pacman::p_install_gh("hrbrmstr/waffle") # waffle charts

