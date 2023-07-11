# Run this file in two parts… 
#
# 1. First run the lines up to drive_auth()
#      … and answer the prompt to choose your username
# 2. Run the remaining lines.

library(googledrive)
library(googlesheets4)

drive_auth()
#-----------------------------
gs4_auth(token = drive_token())

drive_user()

gs4_user()
