deathcount.columns <- c("n","n_state_perp", "n_state_perp_hi",
                       "n_state_victim", "n_state_victim_hi" 
                       #                          "n_state_separate", "n_state_separate_hi",
                       #                          "n_collateral", "n_nonconflict", "n_unconfirmed"
)

red_pal <- function(x) rgb(colorRamp(c("#ffe0e0", "#ff3030", "#bb2020"))(x), maxColorValue = 255)

# deaths columns formatting
deaths_column <- function(maxWidth = 60, class = NULL, maxValue = 100, ...) {
  colDef(
    maxWidth = maxWidth,
    defaultSortOrder = "desc",
    style = function(value) {
      # Lighter color for <1%
      if (value / maxValue < 0.01) {
        list(color = "#888", background="#fff")
      } else {
        list(color = case_when(sqrt(value/ maxValue) < .4 ~ "#111",
                               TRUE ~ "#eee"), 
             background = red_pal(sqrt(value/ maxValue)),
             fontWeight = "bold")
      }
    },
    ...
  )
}

upper_bound_column <- function(min.width=15, ...){
  colDef (name="—", align = "left", format = colFormat(prefix = "– "),
          minWidth = min.width,
          ...
          )
}

wide_event_table <- function(dataset, numerical.columns = deathcount.columns, 
                             incl.campaign=FALSE, static=TRUE, max_larger=0,
                             allow.duplicate.events=FALSE) {
  if(!allow.duplicate.events){
    if(nrow(dataset) > n_distinct(dataset$event_title)) {
       stop("This table contains duplicate event titles. Use allow.duplicate.events=TRUE to ignore.")
    }
  }
  
  # blank the high values if they are the same as the low values…
  dataset<- dataset %>%
    mutate(n_state_perp_hi = ifelse(n_state_perp_hi==n_state_perp, NA, n_state_perp_hi)) %>%
    mutate(n_state_victim_hi = ifelse(n_state_victim_hi==n_state_victim, NA, n_state_victim_hi))
  
  # alternate calculation of span
  max_deaths <- max(select(dataset, n:n_state_victim),  na.rm=TRUE)
  max_deaths <- max(max_deaths, max_larger) # allows the call to include a top value
  
  if(incl.campaign){
    table <-reactable(dataset,
                      filterable=!static,
                      theme = nytimes(),
                      defaultPageSize=25,
                      pageSizeOptions = c(25, 35, 50),
                      showPageSizeOptions=!static,
                      defaultColDef = colDef(
                        filterable=FALSE,
                        defaultSortOrder = "desc",
                        minWidth = 20, maxWidth=60),
                      columnGroups = list(colGroup(name = "deaths", columns = numerical.columns)),
                      columns = list (
                        event_title = colDef (name="Event", minWidth=35, maxWidth=250, 
                                              defaultSortOrder = "asc",
                                              filterable=!static,
                                              style = list(fontWeight = "bold")),
                        year = colDef (name="Year", maxWidth=60, 
                                       defaultSortOrder = "asc",
                                       filterable=!static, sortNALast = TRUE,
                                       style = list(background = "#ffffff")), 
                        protest_campaign = colDef (name="Campaign", minWidth=40, maxWidth=250, 
                                                   defaultSortOrder = "asc",
                                                   filterable=!static,
                                                   style = list(fontWeight = "bold")),
                        n = deaths_column(maxValue = max_deaths, name="Confirmed"),
                        n_state_perp = deaths_column(maxValue = max_deaths, name="State Perp"),
                        n_state_perp_hi = upper_bound_column,
                        n_state_victim = deaths_column(maxValue = max_deaths, name="State Victim"),
                        n_state_victim_hi = upper_bound_column,
                        n_state_separate = deaths_column(maxValue = max_deaths, name="Sep from State"),
                        n_state_separate_hi = upper_bound_column,
                        n_collateral = colDef (name="Collateral",  defaultSortOrder = "desc"),
                        n_nonconflict = colDef (name="Nonconflict", defaultSortOrder = "desc"),
                        n_unconfirmed = colDef (name="Unconfirmed", defaultSortOrder = "desc"),
                        outcome = colDef (name="Outcome", defaultSortOrder = "asc",  minWidth=40, maxWidth = 80,
                                          style = function(value, index) {
                                            if(is.na(dataset$outcome[index])){
                                              list(color = "black")
                                            }else if(dataset$outcome[index] == "Movement"){
                                              list(color = "green")
                                            }else if(dataset$outcome[index] == "State"){
                                              list(color = "red")
                                            }else if(dataset$outcome[index] == "None"){
                                              list(color = "grey")
                                            }
                                          }
                        ),  
                        outcome_summary = colDef (name="Outcome Summary", defaultSortOrder = "asc", minWidth=50, maxWidth = 140,
                                                  style = function(value, index) {
                                                    if(is.na(dataset$outcome[index])){
                                                      
                                                    }else if(dataset$outcome[index] == "Movement"){
                                                      list(background = "#54AE32") #green
                                                    }else if(dataset$outcome[index] == "State"){
                                                      list(background = "#F2806F") # soft red 
                                                    }else if(dataset$outcome[index] == "None"){
                                                      list(background = "#D5D5D5") # light gray
                                                    }
                                                  }),
                        protest_domain = colDef (name="Protest Domain", minWidth=30,
                                                 defaultSortOrder = "asc",
                                                 filterable=!static,
                                                 maxWidth=150),
                        pres_admin = colDef (name="President", minWidth=30,
                                             defaultSortOrder = "asc",
                                             filterable=!static, maxWidth=300)
                      )
    )
  }else{
    dataset <- select(dataset, -protest_campaign)
    table <-reactable(dataset,
                      filterable=!static,
                      theme = nytimes( header_font_color = "#666666"),
                      defaultPageSize=25,
                      showPageSizeOptions=!static,
                      defaultColDef = colDef(
                        filterable=FALSE,
                        defaultSortOrder = "desc",
                        minWidth = 20, maxWidth=60),
                      columnGroups = list(colGroup(name = "deaths", columns =
                                                     numerical.columns)
                      ),
                      columns = list (
                        event_title = colDef (name="Event", minWidth=35, maxWidth=250, 
                                              defaultSortOrder = "asc",
                                              filterable=!static,
                                              style = list(fontWeight = "bold")),
                        year = colDef (name="Year", maxWidth=60, 
                                       defaultSortOrder = "asc",
                                       filterable=!static, sortNALast = TRUE,
                                       style = list(background = "#ffffff")), 
                        n = deaths_column(maxValue = max_deaths, name="Confirmed"),
                        n_state_perp = deaths_column(maxValue = max_deaths, name="State Perp"),
                        n_state_perp_hi = upper_bound_column,
                        n_state_victim = deaths_column(maxValue = max_deaths, name="State Victim"),
                        n_state_victim_hi = upper_bound_column,
                        n_state_separate = deaths_column(maxValue = max_deaths, name="Sep from State"),
                        n_state_separate_hi = upper_bound_column,
                        n_collateral = colDef (name="Collateral",  defaultSortOrder = "desc"),
                        n_nonconflict = colDef (name="Nonconflict", defaultSortOrder = "desc"),
                        n_unconfirmed = colDef (name="Unconfirmed", defaultSortOrder = "desc"),
                        outcome = colDef (name="Outcome", defaultSortOrder = "asc",  minWidth=40, maxWidth = 80,
                                          style = function(value, index) {
                                            if(is.na(dataset$outcome[index])){
                                              list(color = "black")
                                            }else if(dataset$outcome[index] == "Movement"){
                                              list(color = "green")
                                            }else if(dataset$outcome[index] == "State"){
                                              list(color = "red")
                                            }else if(dataset$outcome[index] == "None"){
                                              list(color = "grey")
                                            }
                                          }
                        ),  
                        outcome_summary = colDef (name="Outcome Summary", defaultSortOrder = "asc", minWidth=50, maxWidth = 140,
                                                  style = function(value, index) {
                                                    if(is.na(dataset$outcome[index])){
                                                      
                                                    }else if(dataset$outcome[index] == "Movement"){
                                                      list(background = "#54AE32") #green
                                                    }else if(dataset$outcome[index] == "State"){
                                                      list(background = "#F2806F") # soft red 
                                                    }else if(dataset$outcome[index] == "None"){
                                                      list(background = "#D5D5D5") # light gray
                                                    }
                                                  }),
                        protest_domain = colDef (name="Protest Domain", minWidth=30,
                                                 defaultSortOrder = "asc",
                                                 filterable=!static,
                                                 maxWidth=150),
                        pres_admin = colDef (name="President", minWidth=30,
                                             defaultSortOrder = "asc",
                                             filterable=!static, maxWidth=300)
                      ))
  }
  
  table
}