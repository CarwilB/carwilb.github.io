# create an event count by title that also counts the number of state perpetrator 
#   and state victim deaths
#
library(lubridate)

event.responsibility.dateless <- de %>% group_by(event_title) %>%
  summarize(
    n = n(),
    n_state_perp = sum(state_responsibility=="Perpetrator", na.rm = TRUE),
    n_state_victim = sum(state_responsibility=="Victim", na.rm = TRUE),
    n_state_separate = sum(str_detect(state_responsibility, "Separate"), na.rm = TRUE),
    .groups='drop'
  )

de.first_per_event <- de %>% distinct(event_title, .keep_all=TRUE)

de.first_per_event <- mutate(de.first_per_event,
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

# This test code will show the corrected dates.
# de.first_per_event %>% filter(is.na(day)) %>% select(event_title, date, year, month, day)

# merge the event table with the corresponding year(s)
event.responsibility.dated <- event.responsibility.dateless %>% 
  left_join(unique(select(de.first_per_event, event_title, date, year, protest_domain, pres_admin))) %>%
  select(event_title, date, year, everything()) %>% 
  arrange(date)

event.responsibility <- event.responsibility.dated # use this result as the event responsibility table

event.responsibility3 <- filter(event.responsibility, n>=3)

er.numerical.columns <- c("n","n_state_perp","n_state_victim", 
                          "n_state_separate")
