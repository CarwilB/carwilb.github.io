# WLRF-Tables.Rmd works on the dataset as it was when the article was submitted. 
#
#
# MANUAL STEP
# 
# To calculate a list of events that have altered since, we can run the page, 
# but replace the importing section with a live import.
#
# Saving the table of events from this run in a separate variable.
campaign.events_joined3_2023run <- campaign.events_joined3

# Then re-run the script and generate a fresh campaign.events_joined3
#
# Finally anti-join the two tables
campaign.events_joined_new <- anti_join(campaign.events_joined3_2023run, campaign.events_joined3, 
                                        by=c("protest_campaign", "event_title", "year"))
campaign.events_3_new %>% arrange(year)

# And anti-join in the other direction
campaign.events_joined_new2 <- anti_join(campaign.events_joined3, campaign.events_joined3_2023run, 
                                        by=c("protest_campaign", "event_title", "year"))
campaign.events_joined_new2 

cej_changes <- full_join(campaign.events_3_new, campaign.events_joined_new2,
          by=c("year", "n", "n_state_perp", "n_state_victim")) %>%
          select(year, event_title.x, event_title.y) %>% arrange(year)
cej_changes
