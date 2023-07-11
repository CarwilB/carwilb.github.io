## 01-import.R
#
# This chunk does a non-invasive import of de alone
# and it archives, but does not version it.
#  
#  If live.import is TRUE, it imports the Entries from Google Sheets
#  If live.import is FALSE, it loads the Entries from "deaths-entries-temp.RDS"
#
#  Loads other tables as last archived from pt.filename and es.filename
#  
#  Be sure to include the following ahead of the chunk…
#  live.import <- TRUE

library(here)

source(here::here("src","import-deaths-database-spec1.R"))
# source(here::here("src", "update-versioned-archive.R")) # excluded since we're not archiving

if(live.import){
  de <- import_deaths_database(incl_inactive=FALSE, incl_narrative=FALSE,
                               parse_parenthical=TRUE)
  write_rds(de, file=here::here("data", "deaths-entries-temp.RDS"))
  
}else{
  de <- read_rds(file=here::here("data", "deaths-entries-temp.RDS"))
}
de.filename.dated <- "deaths-entries-temp.RDS"

pt <- read_rds(here::here(pt.filename))
event.status <- read_rds(here::here(es.filename))

datafiles_footer <- function(de=TRUE, pt=FALSE, es=FALSE){
  datafile_text <- ""
  if(de){
    datafile_text <- paste(datafile_text, "**Entries:**", de.filename.dated, sep=" ")
  }
  
  if(pt){
    datafile_text <- paste(datafile_text, "**Presidents:**", pt.filename.dated, sep=" ")
  }
  
  if(es){
    datafile_text <- paste(datafile_text, "**Event Status:**", es.filename.dated, sep=" ")
  }
  
  str_trim(datafile_text)
}