# install.packages("quarto")
library(quarto)

quarto::quarto_render(here::here("ultimate-consequences", "Nested-Table.Rmd"))
