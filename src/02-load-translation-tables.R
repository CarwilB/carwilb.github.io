vt.filename <- "variable-names.rds"
# dtt.filename <- "domain-trans-table.rds"
# ptt.filename <- "presidency-trans-table.rds"

# A Horizontal lookup table
var_name_table <- read_rds(here::here("data", vt.filename))

# A Vertical lookup table: Domains
# domain_trans_table <- read_rds(here::here("data", dtt.filename))
# dtt.orig <- domain_trans_table[, "en"] # lookup key is the column with the English names

# Simple use of this table/lookup pair:
#   pull(domain_trans_table[dtt.orig=="Disabled", "es"])
#
# Mutate a variable using this lookup pair
# def %>% mutate(protest_domain_es = pull(domain_trans_table[dtt.orig==protest_domain,"es"]))

# A Vertical lookup table: Presidency
# pres_trans_table <- read_rds(here::here("data", ptt.filename))
# ptt.orig <- pres_trans_table[, "en"] # lookup key is the column with the English names

# Simple use of this table/lookup pair:
#   pull(pres_trans_table[ptt.orig=="Hugo Banzer (2nd)", "es"])
#.  pull(pres_trans_table[ptt.orig=="Interim military government", "es"])
#
# Mutate a variable using this lookup pair
# def %>% select(event_title, dec_surnames, pres_admin) %>% 
#        mutate(pres_admin_es = pull(pres_trans_table[ptt.orig==as.character(pres_admin),"es"]))
#
# Note 1: as.character is needed because pres_admin is a factor here
# Note 2: Using this method we have to recode the factor levels. Alternatively we could rename the factors.

# translation
#
# A compound list of all the translation tables, labeled by the corresponding variable
# Here's its structure…
# translation <- list(protest_domain = domain_trans_table,
#                     pres_admin = pres_trans_table,
#                     dec_affiliation = affil_trans_table,
#                     perp_affiliation = affil_trans_table, # This duplicate makes referencing easier
#                     cause_death = cause_trans_table,
#                     state_responsibility = sresp_trans_table, 
#                     intentionality = intent_trans_table,
#                     event_title = event_trans_table
# )
translation.tables.filename <- "translation-tables.rds"
translation <- read_rds(here::here("data", translation.tables.filename))
