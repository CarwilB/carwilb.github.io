## 01-import.R
#
#  This is the default importer for RMarkdown scripts in this project
#  
#  If live.import is TRUE, it imports the Deaths and Presidents Table from Google Sheets
#  If live.import is FALSE, it loads these according to de.filename and pt.filename
#
#  If live.importe.es is TRUE, it imports the Event Status Table from Google Sheets
#  If live.import.es is FALSE, it loads this according to es.filename

library(here)

source(here::here("src","import-deaths-database-spec1.R"))
source(here::here("src", "update-versioned-archive.R"))

if (live.import){
  # Import the Entries
  de <- import_deaths_database(incl_inactive=FALSE, incl_narrative=FALSE,
                               parse_parenthical=TRUE)
  #
  # Save current version of the file to data/
  de.filename.dated <- update_versioned_archive(de, de.filename)
  
  # Import the presidents table & save current version of the file
  pt <- import_presidents_table()
  pt.filename.dated <- update_versioned_archive(pt, pt.filename)
  
}else
{
  de <- read_rds(here::here(de.filename))
  pt <- read_rds(here::here(pt.filename))
  
  if(use.current.archive){ # if the filenames are undated, 
    # use the most recent archived file as
    # the file name in question
    # 
    # (potential future upgrade: check that the 
    # undated file contains the same data as this file)
    filelist <-file.info(list.files(path=here::here("data"), pattern="deaths-entries-2.*"), 
                         extra_cols = FALSE)
    filelist <- filelist[with(filelist, order(as.POSIXct(mtime))), ]
    files <- rownames(filelist)
    de.filename.dated <- paste("data/", tail(files, 1), sep="")
    
    filelist <-file.info(list.files(path=here::here("data"), pattern="presidents-table-2.*"), 
                         extra_cols = FALSE)
    filelist <- filelist[with(filelist, order(as.POSIXct(mtime))), ]
    files <- rownames(filelist)
    pt.filename.dated <- paste("data/", tail(files, 1), sep="")
  }else
  {
    de.filename.dated <- de.filename
    pt.filename.dated <- pt.filename
  }
}

if (live.import.es){
  # Import the Event Status table
  event.status <- import_events_table(include_totals = FALSE)
  #
  # Save current version of the file to data/
  #
  es.filename.dated <- update_versioned_archive(event.status, es.filename)
}else
{
  event.status <- read_rds(here::here(es.filename))
  
  if(use.current.es.archive){ # if the filenames are undated, 
    # use the most recent archived file as
    # the file name in question
    # 
    # (potential future upgrade: check that the 
    # undated file contains the same data as this file)
    filelist <-file.info(list.files(path=here::here("data"), pattern="event-status-2.*"), extra_cols = FALSE)
    filelist <- filelist[with(filelist, order(as.POSIXct(mtime))), ]
    files <- rownames(filelist)
    es.filename.dated <- paste("data/", tail(files, 1), sep="")
  }else
  {
    es.filename.dated <- es.filename
  }
}

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