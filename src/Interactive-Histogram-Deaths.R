# install.packages("shiny")
# install.packages("DT")
# install.packages("plotly")

# Library
library(tidyverse)
library(ggplot2)
library(plotly)
library(lubridate)

source(here::here("src","render-age.R"))
source(here::here("src","data-cleaning.R"))
source(here::here("src","colors-material-design.R"))


# Transform the dataset a litte bit to position tiles
don <- de %>% 
  arrange(year) %>% # sort using the numeric variable that interest you
  mutate(y=ave(year, year, FUN=seq_along)) # This calculates the position on the Y axis: 1, 2, 3, 4...

# factor protest_domain
protest_domain.grouped <- c( 
  "Gas Wars",                         # Economic
  "Economic policies",
  "Labor",
  "Education",
  "Mining",
  "Coca",                             # Rural
  "Peasant",
  "Rural Land",
  "Rural Land, Partisan Politics",
  "Ethno-ecological",
  "Drug trade",                       # Criminalized
  "Contraband",
  "Local development",                # Local
  "Municipal governance",
  "Partisan Politics",                # (solo)
  "Disabled",                         # (solo)
  "Guerrilla",                        # Armed actors
  "Paramilitary",
  "Urban land",
  "Unknown")                       # (solo)

protest_domain.colors <- c( 
  "Gas Wars" = mat_color_hex[['blue-900']],
  "Economic policies" = mat_color_hex[['blue-700']],
  "Labor" = mat_color_hex[['blue-500']],
  "Education" = mat_color_hex[['blue-200']],
  "Coca" = mat_color_hex[['green-900']],
  "Peasant" = mat_color_hex[['green-600']],
  "Rural Land" = mat_color_hex[['green-300']],
  "Rural Land, Partisan Politics" = mat_color_hex[['green-200']],
  "Ethno-ecological" = mat_color_hex[['light green-100']],
  "Drug trade" = mat_color_hex[['lime-700']],
  "Contraband" = mat_color_hex[['lime-400']],
  "Mining" = mat_color_hex[['red-700']],
  "Local development" = mat_color_hex[['deep purple-700']],
  "Municipal governance" = mat_color_hex[['deep purple-400']],
  "Partisan Politics" = mat_color_hex[['pink-300']],
  "Disabled" = mat_color_hex[['blue grey-600']],
  "Guerrilla" = mat_color_hex[['brown-800']],
  "Paramilitary" = mat_color_hex[['brown-400']],
  "Urban land" = mat_color_hex[['yellow-500']],
  "Unknown" = mat_color_hex[['grey-300']]
)

don$protest_domain <- fct_explicit_na(don$protest_domain, na_level = "Unknown")
don$protest_domain <- fct_relevel(don$protest_domain, protest_domain.grouped)

# Make the plot (middle)
ggplot(don, aes(x=year, y=y) ) +
  geom_point( size=0.5, color="black" ) 

# Improve the plot, and make it interactive (right)
# add a tooltip segment as a text field
don <- don %>% mutate(name_line = case_when(
                       is.na(dec_age) ~ paste("<b>Name:</b> ", dec_firstname, " ", dec_surnames, "\n", sep=""),
                       TRUE ~ paste("<b>Name:</b> ", dec_firstname, " ", dec_surnames, " (", 
                                    render_age(dec_age), ")\n", sep="")))

don <- don %>% mutate(age_text = render_age(dec_age))

don <- don %>% mutate(month_name = month.name[month],
  date_text = case_when(
  (is.na(day) &
     is.na(month) & !is.na(year)) ~ str_glue("in {year}"),
  (is.na(day) &
     !is.na(month) &
     !is.na(year)) ~ str_glue("in {month.name[month]} {year}"),
  (is.na(year)) ~  "on unknown date",
  # Normal date are just pasted
  TRUE ~ (str_glue("on {day} {month_name} {year}"))
  ),
  incident_line = str_c("Fatal incident ", date_text)
 )

don <- don %>% mutate(tooltiptext=paste("<b>", event_title, "</b>\n", 
                                        name_line,
                                        "<b>Affiliation:</b> ", dec_affiliation, "\n", 
                                        state_responsibility, " | ", intentionality, "\n", 
                                        "<b>Event:</b> ", event_title, "\n", 
                                        "<b>Cause of death:</b> ", cause_death, "\n",
                                        incident_line, sep="")) 
#


# plot the histogram
# p <- ggplot(don, aes(x=year, y=y) ) +
#   geom_point( aes(text=tooltiptext), size=2, color="black", shape=18 ) +
#   xlab('Year') +
#   ylab('# of individuals') +
#   theme_classic() +
#   theme(
#     legend.position="none",
#     axis.line.y = element_blank(),
#     axis.text=element_text(size=15)
#   )
# p

p <- ggplot(don, aes(x=year, y=y) ) +
  geom_tile( aes(text=tooltiptext, fill=protest_domain), height=0.9) +
  xlab('Year') +
  ylab('# of individuals') +
  scale_x_continuous(limits=c(1982, 2025),
                     breaks =c(1982, 1990, 2000, 2010, 2020), expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  scale_fill_manual(limits = protest_domain.grouped, 
                    values = protest_domain.colors, 
                    guide = guide_legend(title="Domain of Protest",
                                         reverse=FALSE)) +
  theme_classic() +
  theme(
    legend.position="right",
    axis.line.y = element_blank(),
    axis.text=element_text(size=15)
  )
p

# Use the magic of ggplotly to have an interactive version
ggplotly(p, tooltip="text") %>% layout(hoverlabel=list(bgcolor="white"))

## Same thing but for protest domain
p <- ggplot(don, aes(x=year, y=y) ) +
  geom_tile( aes(text=tooltiptext, fill=department), width=0.95, height=0.8) +
  xlab('Year') +
  ylab('# of individuals') +
  scale_x_continuous(limits=c(1982, 2025),
                     breaks =c(1982, 1990, 2000, 2010, 2020), expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  # scale_fill_manual(limits = protest_domain.grouped, 
  #                   values = protest_domain.colors, 
  #                   guide = guide_legend(reverse=FALSE)) +
  theme_classic() +
  theme(
    legend.position="right",
    axis.line.y = element_blank(),
    axis.text=element_text(size=15)
  )
p

## Same thing but for state_responsibility
p <- ggplot(don, aes(x=year, y=y) ) +
  geom_tile( aes(text=tooltiptext, fill=state_responsibility), width=0.95, height=0.9) +
  xlab('Year') +
  ylab('# of individuals') +
  scale_x_continuous(limits=c(1982, 2025),
                     breaks =c(1982, 1990, 2000, 2010, 2020), expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  scale_fill_manual(limits = sr_levels, values = state_resp.colors, 
                    guide = guide_legend(title="Role of the State")) +
  theme_classic() +
  theme(
    legend.position="right",
    axis.line.y = element_blank(),
    axis.text=element_text(size=15)
  )
p

ggplotly(p, tooltip="text") %>% layout(hoverlabel=list(bgcolor="white"))

