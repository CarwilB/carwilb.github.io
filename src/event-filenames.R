select(event.responsibility3, event_title) -> event.titles3

event.titles3 <- event.titles3 %>% mutate(event.filename=str_to_lower(str_replace_all(event_title, "\\s+", "-"))) %>%
                  mutate(event.filename=stringi::stri_trans_general(event.filename, "Latin-ASCII")) %>%
                  mutate(event.filename= str_c(event.filename, ".md")) %>%
                  arrange(event.filename)
