library(tidyverse)
library(googledrive)
library(googlesheets4)


filename <- "Bolivia Deaths Database"
database_file <- drive_find(filename, n_max=1) # drive_find returns a dataframe of matching files
# By setting n_max=1, we limit to one file
# The files are sorted newest first, so this gives the newest version in the drive

# this inactive code looks at metadata for the file
gs4_get(database_file)
# Import the Entries
domain_trans_table <- range_read(ss=database_file, col_names = TRUE,
                        range = "DomainTranslationTable")

dtt.filename <- "data/domain-trans-table.rds"
update_versioned_archive(domain_trans_table, dtt.filename)

# domain_trans_table <- read_rds(here::here(dtt.filename)) 

# deploy by using this:
# left_join(de.cochabamba, domain_trans_table, by = c('protest_domain' = 'en')) %>% rename(protest_domain_es = es)
# or this:
# def %>% mutate(protest_domain_es = pull(domain_trans_table[dtt.orig==protest_domain,"es"]))

# pres_admin
pres_trans_table <- range_read(ss=database_file, col_names = TRUE,
                                 range = "PresidencyTranslationTable")

ptt.filename <- "data/presidency-trans-table.rds"
update_versioned_archive(pres_trans_table, ptt.filename)

# affiliation: dec_affiliation, perp_affiliation
affil_trans_table <- range_read(ss=database_file, col_names = TRUE,
                                   range = "AffiliationTranslationTable")
att.filename <- "data/affiliation-trans-table.rds"
update_versioned_archive(affil_trans_table, att.filename)

# cause_death
cause_trans_table <- range_read(ss=database_file, col_names = TRUE,
                               range = "CauseDeathTranslationTable")
cdtt.filename <- "data/cause-death-trans-table.rds"
update_versioned_archive(cause_trans_table, cdtt.filename)

# state_responsibility
sresp_trans_table <- range_read(ss=database_file, col_names = TRUE,
                                range = "StateResponsibilityTranslationTable")
srtt.filename <- "data/state-responsibility-trans-table.rds"
update_versioned_archive(sresp_trans_table, srtt.filename)

# intentionality
intent_trans_table <- range_read(ss=database_file, col_names = TRUE,
                                range = "IntentionalityTranslationTable")
itt.filename <-  "data/intentionality-trans-table.rds"
update_versioned_archive(intent_trans_table, itt.filename)

# intentionality
event_trans_table <- range_read(ss=database_file, col_names = TRUE,
                                 range = "EventTitleTranslationTable")
ett.filename <-  "data/event-trans-table.rds"
update_versioned_archive(event_trans_table, ett.filename)

# A compound list of all the translation tables, labeled by the corresponding variable
translation <- list(protest_domain = domain_trans_table,
                    pres_admin = pres_trans_table,
                    dec_affiliation = affil_trans_table,
                    perp_affiliation = affil_trans_table, # This duplicate makes referencing easier
                    cause_death = cause_trans_table,
                    state_responsibility = sresp_trans_table, 
                    intentionality = intent_trans_table,
                    event_title = event_trans_table
                    )
translation.tables.filename <- here::here("data","translation-tables.rds")
update_versioned_archive(translation, translation.tables.filename)

# Test scripts follow…

# translation$intentionality[translation$intentionality$en=="Direct", "es"]
# 
# left_join(de.cochabamba, translation$intentionality, by = c("intentionality"="en")) %>% rename(intentionalidad = es)
# 
# de %>% 
#   left_join(translation$pres_admin, by = c("pres_admin"="en")) %>% 
#   rename(pres_admin_es = es) %>%
#   left_join(translation$dec_affiliation, by = c("dec_affiliation"="en")) %>% 
#   rename(dec_affiliation_es = es) %>%
#   left_join(translation$perp_affiliation, by = c("perp_affiliation"="en")) %>% 
#   rename(perp_affiliation_es = es) %>%
#   left_join(translation$state_responsibility, by = c("state_responsibility"="en")) %>% 
#   rename(state_responsibility_es = es) %>%
#   left_join(translation$intentionality, by = c("intentionality"="en")) %>% 
#   rename(intentionality_es = es) %>%
#   select(event_title, dec_firstname, dec_surnames, pres_admin_es, dec_affiliation_es, 
#          perp_affiliation_es, state_responsibility_es, intentionality_es)

# unsatisfactory experiment
#
# translate_t <- function(variable, text, in_language="en", out_language="es", trans_table=translation){
#   name <- substitute(variable)
#   translation_table <- translation[[name]]
#   translation_key <- translation_table[[in_language]]
#   pull(translation_table[translation_key==text, out_language])
# }
