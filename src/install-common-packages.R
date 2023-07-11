# load packages
install.packages("googlesheets4") # access to Google Sheets
# Make sure you run this separately since it needs keyboard input

install.packages("tidyverse")
install.packages("openssl")
install.packages("devtools")
install.packages("gitcreds")
install.packages("usethis") # enables remote management of github

install.packages('treemapify')

install.packages("naniar") # analyzes missing values
install.packages("arsenal") # makes pretty summary tables
install.packages("skimr") # characterizes the variables
install.packages("scales") # number formatting
install.packages("lubridate")
install.packages("RColorBrewer")
install.packages("janitor") # data cleaning, includes tabyl
install.packages("reactable") # interactive tables
install.packages("reactablefmtr") # style and heatmap formatting for reactable
install.packages("V8") # enables static versions of reactables
install.packages("kable") 
install.packages("ggalluvial")
install.packages("ggrepel")
install.packages("gghighlight")
install.packages("flextable")
install.packages("GGally")
install.packages("hrbrthemes")
install.packages("webshot")
install.packages("magick")
install.packages("kableExtra")
install.packages("english")
install.packages("datawizard")


install.packages("ggthemes")
install.packages("ggtext")
install.packages("ggfittext")

install.packages('stringdist') # fuzzy string matching

devtools::install_github("yogevherz/plotme") # transforms data frames for plotly formats
devtools::install_github("hrbrmstr/waffle") # waffle charts

# activate libraries
library(tidyr)
library(readr)
library(dplyr)
library(ggplot2)
library(forcats)
library(googlesheets4)
library(googledrive)
library(stringr)
library(scales) # Utilities for scales and formatting
library(lubridate)
library(treemapify)

### Option 2: Install packages while testing to see if they are installed first
# Package names
# packages <- c("ggplot2", "readxl", "dplyr", "tidyr", "ggfortify", "DT", "reshape2", "knitr", "lubridate", "pwr", "psy", "car", "doBy", "imputeMissings", "RcmdrMisc", "questionr", "vcd", "multcomp", "KappaGUI", "rcompanion", "FactoMineR", "factoextra", "corrplot", "ltm", "goeveg", "corrplot", "FSA", "MASS", "scales", "nlme", "psych", "ordinal", "lmtest", "ggpubr", "dslabs", "stringr", "assist", "ggstatsplot", "forcats", "styler", "remedy", "snakecaser", "addinslist", "esquisse", "here", "summarytools", "magrittr", "tidyverse", "funModeling", "pander", "cluster", "abind")

# Install packages not yet installed
#installed_packages <- packages %in% rownames(installed.packages())
# if (any(installed_packages == FALSE)) {
#   install.packages(packages[!installed_packages])
# }

# ### Option 3: Pacman package manager is in install-packages.R
# if (!require("pacman")) install.packages("pacman") #install pacman if it's not there
# 
# pacman::p_load(
#   # This list of packages is a fork of the Epidemiologist R Handbook's list
#   # https://epirhandbook.com/suggested-packages-1.html
#   #
#   # package install and management
#   ################################
#   pacman,   # package install/load
#   renv,     # managing versions of packages when working in collaborative groups
#   remotes,  # install from github
#   
#   # General data management
#   #########################
#   tidyverse,    # includes many packages for tidy data wrangling and presentation
#   #dplyr,      # data management
#   #tidyr,      # data management
#   #ggplot2,    # data visualization
#   #stringr,    # work with strings and characters
#   #forcats,    # work with factors 
#   #lubridate,  # work with dates
#   #purrr       # iteration and working with lists
#   linelist,     # cleaning linelists
#   naniar,       # assessing missing data
#   skimr,         # characterizes the variables
#   
#   # statistics  
#   ############
#   janitor,      # tables and data cleaning
#   arsenal,      # makes pretty summary tables
#   #  gtsummary,    # making descriptive and statistical tables
#   #  rstatix,      # quickly run statistical tests and summaries
#   #  broom,        # tidy up results from regressions
#   #  lmtest,       # likelihood-ratio tests
#   #  easystats,
#   # parameters, # alternative to tidy up results from regressions
#   # see,        # alternative to visualise forest plots
#   
#   # plots - general
#   #################
#   # ggplot2,         # included in tidyverse
#   cowplot,          # combining plots  
#   # patchwork,      # combining plots (alternative)     
#   RColorBrewer,     # color scales
#   # ggnewscale,       # to add additional layers of color schemes
#   
#   # plots - specific types
#   ########################
#   #  DiagrammeR,       # diagrams using DOT language
#   #  incidence2,       # epidemic curves
#   #  gghighlight,      # highlight a subset
#   #  ggrepel,          # smart labels
#   plotly,           # interactive graphics
#   #  gganimate,        # animated graphics 
#   ggalluvial        # alluvial / Sankey plots
#   
# )
# 
