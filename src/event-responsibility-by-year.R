# create an event count by title that also counts the number of state perpetrator 
#   and state victim deaths
#
# This superceded version uses both event_title and year as index variables, 
# causing certain complications.
event.responsibility <- de %>% group_by(event_title, year) %>%
  summarize(
    n = n(),
    n_state_perp = sum(state_responsibility=="Perpetrator", na.rm = TRUE),
    n_state_victim = sum(state_responsibility=="Victim", na.rm = TRUE),
    n_state_separate = sum(str_detect(state_responsibility, "Separate"), na.rm = TRUE),
    .groups='drop'
  ) %>%
  arrange(desc(n))

# merge the event table with the corresponding year(s)
event.responsibility <- event.responsibility %>% 
  left_join(unique(select(de, event_title, year, protest_domain, pres_admin))) %>%
  select(event_title, year, everything())

# Now, cull duplicate rows from our summary table
#
# This method separates events with the same name but different year correctly.
# But, this method also suppresses some information when an event-year pair
# has different values for protest_domain or pres_admin.
#
# Future work: A really smart algorithm would find the non-distinct values 
# and put them both into the corresponding text field.
#
event.responsibility <- event.responsibility %>% 
  distinct(event_title, year, .keep_all=TRUE)

# here is where we select for larger events; remove if we want them all
event.responsibility3 <- filter(event.responsibility, n>=3)

er.numerical.columns <- c("n","n_state_perp","n_state_victim", 
                          "n_state_separate")