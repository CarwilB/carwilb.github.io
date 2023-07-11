## 01-import-settings-live.R

live.import <- TRUE
live.import.es <- FALSE # The event status table is relatively volatile, 
# so only switch this on when we need new outcome data

de.filename <- "data/deaths-entries.rds"
pt.filename <- "data/presidents-table.rds"
es.filename <- "data/event-status.rds"

use.current.archive <- TRUE # This flag should be set to true when
# the above filenames do not have a date
use.current.es.archive <- TRUE # This flag should be set to true when
# es.filename does not have a date