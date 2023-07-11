# This script loads existing translation tables into their own variables.
#
# It's useful when we're building out the meta table called translation
#
# To add a new variable. Load all of the prior ones alongside the new one

vt.filename <- "variable-names.rds"
dtt.filename <- "domain-trans-table.rds"
ptt.filename <- "presidency-trans-table.rds"
att.filename <- "affiliation-trans-table.rds"
cdtt.filename <- "cause-death-trans-table.rds"
srtt.filename <- "state-responsibility-trans-table.rds"
itt.filename <-  "intentionality-trans-table.rds"
ett.filename <-  "event-trans-table.rds"

var_name_table <- read_rds(here::here("data", vt.filename))
domain_trans_table <- read_rds(here::here("data", dtt.filename))
pres_trans_table <- read_rds(here::here("data", ptt.filename))
affil_trans_table <- read_rds(here::here("data", att.filename))
cause_trans_table <- read_rds(here::here("data", cdtt.filename))
sresp_trans_table <- read_rds(here::here("data", srtt.filename))
intent_trans_table <- read_rds(here::here("data", itt.filename))
event_trans_table <- read_rds(here::here("data", ett.filename))

# translation
#
# A compound list of all the translation tables, labeled by the corresponding variable
# Here's its structure…
translation <- list(protest_domain = domain_trans_table,
                    pres_admin = pres_trans_table,
                    dec_affiliation = affil_trans_table,
                    perp_affiliation = affil_trans_table, # This duplicate makes referencing easier
                    cause_death = cause_trans_table,
                    state_responsibility = sresp_trans_table, 
                    intentionality = intent_trans_table,
                    event_title = event_trans_table
)

# To save the new version, use this code

translation.tables.filename <- here::here("data","translation-tables.rds")
update_versioned_archive(translation, translation.tables.filename)

