# clean_pt_variables()
# This function cleans up variable names from the presidents table

clean_pt_variables <- function(pt){
  stopifnot(is.tbl(pt))
  pt <- rename_with(pt, ~ sub(" \\(.*", "", .x))
  pt <- rename_with(pt, ~ tolower(gsub(" ", "_", .x, fixed = TRUE)))
  pt <- rename_with(pt, ~ gsub("frequency_of_", "", .x, fixed = TRUE))   
  pt <- rename_with(pt, ~ gsub("-", "_", .x, fixed = TRUE))     
  pt <- rename_with(pt, ~ gsub("/", "_", .x, fixed = TRUE))     
  pt <- rename_with(pt, ~ gsub("?", "", .x, fixed = TRUE))   
  
  return(pt)
}

assign_presidency_levels <- function(dataframe){
  president_levels <<- c(
    "Hernán Siles Zuazo", "Víctor Paz Estenssoro", "Jaime Paz Zamora", 
    "Gonzalo Sanchez de Lozada (1st)", "Hugo Banzer (2nd)", "Jorge Quiroga",
    "Gonzalo Sanchez de Lozada (2nd)", "Carlos Diego Mesa Gisbert", 
    "Eduardo Rodríguez", "Evo Morales", "Interim military government", 
    "Jeanine Áñez", "Luis Arce")
  president_initials <<- c(
    "HSZ", "VPE", "JPZ", 
    "GSL", "HB", "JQ",
    "GSL", "CM", 
    "ER", "EM", "Mil", 
    "JA", "LA")
  
  # This complicated construction ensures that no errors will be generated if there is no pres_admin column
  if (!("pres_admin" %in% colnames(dataframe))) return(dataframe)
  
  dataframe <- dataframe %>% mutate(pres_admin = factor(pres_admin, levels=president_levels))
  return(dataframe)
}

assign_state_perpetrator_levels <- function(dataframe, simplify=FALSE){
  de <- dataframe
  de$state_perpetrator <- str_to_title(de$state_perpetrator)
  de$state_perpetrator <- fct_explicit_na(de$state_perpetrator, na_level = "Unknown")
  if (simplify){
    de$state_perpetrator <- fct_collapse(de$state_perpetrator, 
                                         Yes = c("Yes", "Likely Yes", "Presumed Yes"), 
                                         Indirect = c("Indirect"),
                                         No = c("No", "Likely No"),
                                         Mutiny = c("In Mutiny"),
                                         Unknown  = c("Unknown", "Disputed", "Suspected") ) %>% suppressWarnings()
    de$state_perpetrator <- fct_relevel(de$state_perpetrator, 
                                        c("Unknown", "No", "Indirect", "Mutiny", "Yes")) # default ordering
  }
  return(de)
}

combine_dates <- function(dataframe, incl_laterdate=FALSE){
  dataframe <- mutate(dataframe,
                      date = case_when(
                        # Manage dates where we know year (and possibly month) but not the whole date
                        # These dates are estimates in the middle of the year or month
                        (is.na(day) &
                           is.na(month) & !is.na(year)) ~ as.Date(str_glue("{year}-06-30")),
                        (is.na(day) &
                           !is.na(month) &
                           !is.na(year)) ~ as.Date(str_glue("{year}-{month}-15")),
                        (is.na(year)) ~ NA,
                        # Normal date are just pasted
                        TRUE ~ (paste(year, month, day, sep = "-") %>%
                                  ymd() %>% as.Date())
                      ),
                      date_text = format(date, "%Y-%m-%d")) 
  
  if(incl_laterdate & ("later_day" %in% colnames(dataframe))){
    dataframe <- mutate(dataframe,
                        laterdate = (paste(later_year, later_month, later_day, sep="-") %>% 
                                       ymd() %>% as.Date()))
  }
  dataframe
}