# update-versioned-archive.R
# Created by Carwil Bjork-James on April 1, 2021
#
# This script handles archiving each version of the dataset that we import. 
# 
# Known issues: 
# 1. granularity is one archive per day 
# 2. Assumes that the most recent dated version is equal to the current version
#    (as it should be if created by update_versioned_archive())
# 3. Curretly there is no metadata stored other than the date in the filename
# 4. We haven't yet created any functional tools to load and verify data from 
#    these RDS files, though read_rds() may be adequate.

# function to add the current date to a filepath before the extension

append_current_date <- function(filename="filename.ext"){
  library("tools")
  library("lubridate")
  path <- file_path_sans_ext(filename)
  extension <- file_ext(filename)
  dated_filename <- paste(path, "-", Sys.Date(), ".", extension, sep="")
}

# function to check if a variable that matches its saved version,
# and if it does not, replace the saved version and save a dated copy
#
# This function returns the name of the dated file, allowig it to be used
# in the reproducibility metadata for any and all charts and reports.

update_versioned_archive <- function(df, filename="filename.ext") {
  library("tools")
  library(dplyr)
  library(janitor)
  if (!file.exists(filename)) {
    # if there is no archive of the file yet, create a first archive
    write_rds(df, file=filename) 
    filename.dated <- append_current_date(filename)
    write_rds(df, file=filename.dated)
  } else{
    # otherwise do a comparison with the saved version
    df.saved<-read_rds(filename)
    if(isTRUE(all_equal(df, df.saved))) {
        # if the newly imported df is the same as the saved one, do nothing.
        # 
        # and also save the filename of newest version  
        df.filelist <- file.info(list.files(dirname(filename), 
                                            pattern = paste(basename(file_path_sans_ext(filename)), "-", sep=""), 
                                            full.names = T)) 
        filename.dated <- rownames(df.filelist)[which.max(df.filelist$mtime)]
    }else{
      # if the newly imported dataframe is different, overwrite the current file
      write_rds(df, file=filename)
      # and also save a copy with today's date
      filename.dated <- append_current_date(filename)
      write_rds(df, file=filename.dated) 
    }
    rm(df.saved) # and remove the old copy from memory
  }
  return(filename.dated)
}

# de.filename <- "data/deaths-entries.rds"
# if !file.exists(de.filename)
# # if there is no archive of the file yet, create a first archive
# write_rds(de, file=de.filename) 
# de.filename.dated <- append_current_date(de.filename)
# write_rds(de, file=de.filename.dated)
# } else{
#   # otherwise do a comparison with the saved version
#   de.saved<-read_rds(filename)
#   if(all_equal(de, de.saved) {
#     # if the newly imported de is the same as the saved one, do nothing.
#     # 
#     # and also save the filename of newest version  
#     de.filelist <- file.info(list.files(dirname(de.filename), 
#                                         pattern = paste(basename(file_path_sans_ext(de.filename)), "-", sep=""), 
#                                         full.names = T)) 
#     de.filename.dated <- rownames(de.filelist)[which.max(df$mtime)]
#     
#   }else{
#     # if the newly imported de is different, overwrite the current file
#     write_rds(de, file=de.filename)
#     # and also save a copy with today's date
#     de.filename.dated <- append_current_date(de.filename)
#     write_rds(de, file=de.filename.dated) 
#     
#     #   de.filename <- paste("data/deaths-entries", "-", Sys.Date(), ".rds", sep="") # filename with current date
#   }
#   rm(de.saved) # and remove the old copy from memory
# }