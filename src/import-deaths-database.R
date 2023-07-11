# clean_dates(), 
# A function that processes multiple options:
# 1.It treats blanks as "unknown", but only if there is in fact a date.
# 2.It treats the first date in the text field as numerical date
# 3.It saves the whole non-numerical field as a note in a relevant variable. 

clean_dates <- function(de_chardates){
  de_chardates <- de_chardates %>% 
    mutate(day_notes = case_when(is.na(day) ~ "Unknown day",
                                 !str_detect(day,"^([0-9]*)$") ~ day,
                                 TRUE ~ ""
    ))
  de_chardates <- de_chardates %>% 
    mutate(month_notes = case_when(is.na(month) ~ "Unknown month",
                                   !str_detect(month,"^([0-9]*)$") ~ month, 
                                   TRUE ~ ""
    ))
  de_chardates <- de_chardates %>% 
    mutate(year_notes = case_when(is.na(year) ~ "Unknown year",
                                  !str_detect(year,"^([0-9]*)$") ~ year, 
                                  TRUE ~ ""
    ))

  de_chardates <- de_chardates %>% 
    mutate(later_date_flag = !(is.na(later_day) & is.na(later_month) & is.na(later_year))) # this flag is true if there is later date

# Diagnostic variable lets us see if that worked. 
#
#  de_test <- de_chardates %>%
#    select(later_year, later_month, later_day, later_date_flag)
  
    de_chardates <- de_chardates %>% 
      mutate(later_day_notes = case_when(later_date_flag==FALSE ~ "", # return nothing if all three columns are blank
                                         is.na(later_day) ~ "Unknown day",
                                         !str_detect(later_day,"^([0-9]*)$") ~ day,
                                         TRUE ~ ""
      ))
    de_chardates <- de_chardates %>% 
      mutate(later_month_notes = case_when(!later_date_flag ~ "", # return nothing if all three columns are blank
                                           is.na(later_month) ~ "Unknown month",
                                           !str_detect(later_month,"^([0-9]*)$") ~ month, 
                                           TRUE ~ ""
      ))
    de_chardates <- de_chardates %>% 
      mutate(later_year_notes = case_when(!later_date_flag ~ "", # return nothing if all three columns are blank
                                          is.na(later_year) ~ "Unknown year",
                                          !str_detect(later_year,"^([0-9]*)$") ~ year, 
                                          TRUE ~ ""
      ))
    de_chardates <- de_chardates %>% select(-later_date_flag) # Remove temporary flag
       
  de_chardates <- de_chardates %>% 
    mutate_at(c("year", "month", "day", "later_year", "later_month", "later_day"), str_extract, "\\d+")
#    mutate(across(.cols = year:later_day, .fns = str_extract, pattern = "\\d+"))
  
  de_chardates <- de_chardates %>% 
    mutate_at(c("year", "month", "day", "later_year", "later_month", "later_day"), as.integer) 
#    mutate(across(.cols = year:later_day, .fns = as.integer) )

  return(de_chardates)
}

# A simple function to import the database from Google Sheets

import_deaths_database <- function(filename="Bolivia Deaths Database", 
                                   numeric_dates=FALSE, char_date_cleaning=TRUE,
                                   incl_inactive=FALSE, incl_narrative=FALSE,
                                   parse_parenthical=TRUE){
    # get the Bolivia database google sheet
    database_file <- drive_find(filename, n_max=1) # drive_find returns a dataframe of matching files
                                                   # By setting n_max=1, we limit to one file
                                                   # The files are sorted newest first, so this gives the newest version in the drive

    # Import the Entries
    if(numeric_dates) {
      datasheet <- read_sheet(ss=database_file, sheet = "Entries", 
                              col_types = "cliiiiiicciccccccccccccccccccccccccccccccccccccccccccccccccicc", 
                              skip = 3, trim_ws = TRUE) # omitted: comment="#"
    } else
    { #process dates as characters
      datasheet <- read_sheet(ss=database_file, sheet = "Entries", 
                              col_types = "clcccccccccccccccccccccccccccccccccccccccccccccccccccccccccicc", 
                              skip = 3, trim_ws = TRUE) # omitted: comment="#"
    }    

    datasheet <- datasheet %>% drop_na(event_title) # remove null rows
    datasheet <- filter(datasheet,substr(event_title,1,1)!="#") # remove commented rows
    datasheet <- filter(datasheet, !str_detect(event_title, pattern = "^[0-9]+$")) # remove initial number rows (summary data at bottom)
    
    if(!numeric_dates & char_date_cleaning){
      datasheet <- clean_dates(datasheet)
    }
    
    if(incl_inactive==FALSE){
      datasheet <- select(datasheet, -victim_compensated, 
                   -disciplinary_acct,
                   -judicial_acct,
                   -hr_report,
                   -coldblood,
                   -outcomes,
                   -refs_outcomes) # drop currently inactive columns per flag
    }
    
    if(incl_narrative==FALSE){
      datasheet <- select(datasheet, -complications,
                          -notes,
                          -refs,
                          -see_also) # drop extended narrative columns per flag
    }
    
    if(parse_parenthical==TRUE){
      # handle parenthetical annotations
      datasheet <- datasheet %>% 
        tidyr::separate(col = "state_perpetrator", sep = "\\s\\(", fill ="right", into = c("state_perpetrator","sp_notes")) %>%
        mutate(sp_notes = str_remove(sp_notes, "\\)"))
      
      datasheet <- datasheet %>% 
        tidyr::separate(col = "victim_armed", sep = "\\s\\(", fill ="right", into = c("victim_armed","va_notes")) %>%
        mutate(va_notes = str_remove(va_notes, "\\)"))
      
      datasheet<- datasheet %>% 
        tidyr::separate(col = "state_responsibility", sep = "\\s\\(", 
                        fill ="right", into = c("state_responsibility","sr_notes")) %>%
        mutate(sr_notes = str_remove(sr_notes, "\\)"))
    }
    
    return(datasheet)
}

# Future plans: 
# 1. 
# 2. Load from a GitHub repository
# 3. Some kind of language option, where English / Spanish are both stored in the dataset 
# 4. A smarter method for column types that is less vulnerable to changes in the database
#
# Outside of this function: filtering, factoring, data checking, assertive programming

# Also, a simple function to import the presidents table from Google Sheets

import_presidents_table <- function(filename="Bolivia Deaths Database"){
    # get the Bolivia database google sheet
    database_file <- drive_find(filename, n_max=1) # drive_find returns a dataframe of matching files
     # By setting n_max=1, we limit to one file
     # The files are sorted newest first, so this gives the newest version in the drive
  
    # Import the Entries
    datasheet <- read_sheet(ss=database_file, sheet = "by Presidency", 
                            range = "by Presidency!A1:L30",
                            trim_ws = TRUE)
    datasheet
}

# Also, a simple function to import the "Event Status" page from Google Sheets

import_events_table <- function(filename="Bolivia Deaths Database", include_totals=FALSE){
  # get the Bolivia database google sheet
  database_file <- drive_find(filename, n_max=1) # drive_find returns a dataframe of matching files
                                                 # By setting n_max=1, we limit to one file
                                                 # The files are sorted newest first, so this gives the newest version in the drive
  
  # Import the Entries
  datasheet <- read_sheet(ss=database_file, sheet = "Event status", 
                          col_types = "ciiiiiiiciiiccccccccccccccc", 
                          range = "Event status!A2:AA",
                          skip=1,
                          trim_ws = TRUE) %>%
              filter(!is.na(event_title))

    if(!include_totals)
  {
    datasheet <- datasheet %>%
                 filter(event_title!="Total")      
  }

  datasheet
}

# The following code lets us check that the import of the 'Event Status' sheet works
#
# events <- import_events_table(include_totals = TRUE)
# skim(events)

# import_variable_name_table is useful for customizing headers for variables
# and for localization by language.
#
# Since future localization will require changing the cell range, we opt instead
# use Google Sheet's "Named Ranges" functionality.

import_variable_name_table <- function(filename="Bolivia Deaths Database"){
  # get the Bolivia database google sheet
  database_file <- drive_find(filename, n_max=1) # drive_find returns a dataframe of matching files
  # By setting n_max=1, we limit to one file
  # The files are sorted newest first, so this gives the newest version in the drive
  
  # this inactive code looks at metadata for the file
  gs4_get(database_file)
  # Import the Entries
  datanames <- range_read(ss=database_file, col_names = FALSE,
                          range = "VariableTable")
  datanames <- tail(datanames, 1)
  datanames <- unlist(datanames[1,])
  
  var_name_table <- range_read(ss=database_file, col_names = datanames,
                          range = "VariableTable") %>%
               select(!starts_with("...")) %>%
               rename(language = r_variable)
  
  var_name_table
}


