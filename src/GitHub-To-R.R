# This script follows the steps laid out here: 
# https://happygitwithr.com/credential-caching.html

install.packages("usethis")

## Use the following code only when you need to create a new PAT token
# usethis::create_github_token()

library(gitcreds)

gitcreds_set()
