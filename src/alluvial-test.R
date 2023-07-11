# Two different installations…
# 
# A prior version
install_version("ggalluvial", version = "0.12.3", repos = "http://cran.us.r-project.org")
# the development build.
remotes::install_github("corybrunson/ggalluvial@main", build_vignettes = TRUE)

# THe following is the sample script for ggalluvial.
# If it doesn't work, then the problem isn't with our code.

library(ggalluvial)

titanic_wide <- data.frame(Titanic)
head(titanic_wide)

ggplot(data = titanic_wide,
       aes(axis1 = Class, axis2 = Sex, axis3 = Age,
           y = Freq)) +
  scale_x_discrete(limits = c("Class", "Sex", "Age"), expand = c(.2, .05)) +
  xlab("Demographic") +
  geom_alluvium(aes(fill = Survived)) +
  geom_stratum(width = .2) +
  geom_text(stat = "stratum", aes(label = after_stat(stratum))) +
  theme_minimal() +
  ggtitle("passengers on the maiden voyage of the Titanic",
          "stratified by demographics and survival")
