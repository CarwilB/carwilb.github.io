## 01-import-variable-table.R
#
#  This is an importer for RMarkdown scripts in this project which imports
#  a table of variable names. This is an infrequently changing list of variables, 
#  and this importer should NOT be part of a repeated workflow.
#  
#  If live.import is TRUE, it imports the Variable Table from Google Sheets
#  If live.import is FALSE, it the saved version from the repository
#
#  This script omits functionality for always providing dates for variable names.

library(here)

source(here::here("src","import-deaths-database.R"))
source(here::here("src","update-versioned-archive.R"))

vt.filename <- "variable-names.rds"

if (live.import){
  # Import the Entries
  var_name_table <- import_variable_name_table()
  #
  # Save current version of the file to data/
  vt.filename.dated <- update_versioned_archive(var_name_table, vt.filename)
}else
{
  var_name_table <- read_rds(here::here("data",vt.filename)) 
}

variable_name <- function(variable, lang="en", name_table = var_name_table){
  variable <- substitute(variable)
  row_of_names_for_language <- name_table %>% filter(language == lang)
  if (any(names(row_of_names_for_language)==variable)){
    pull(row_of_names_for_language[1, variable])
  }else{
    substitute(variable)
  }
}
