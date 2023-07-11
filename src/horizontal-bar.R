library(ggplot2)
library(ggthemes)

# create a sample tibble with some random data
my_data <- tibble(x = sample(letters[1:5], 100, replace = TRUE))

# create a stacked bar chart using ggplot2
ggplot(my_data, aes(x, fill = x)) +
  geom_bar() +
  labs(title = "Stacked bar chart of values in my_data",
       x = "Values of x",
       y = "Number of observations")

my_data %>%  
  count(x) %>%
  ggplot(aes(x = "", y = n, fill = x)) + 
  geom_col(width = .10) + 
#  scale_fill_manual(values = c("black", "#039dfc", "yellow")) + 
  coord_flip() +
  theme_void() +
  geom_text(
    aes(label = paste(x, ":", n)), 
    position = position_stack(vjust = 0.95),
    hjust = 1, 
    size = 8, fontface = "bold", family = "Roboto Condensed"
  )

de_event <- de %>% filter(event_title=="Gas War 2003")

de_event %>%  
  count(dec_affiliation) %>%
  mutate(x=dec_affiliation) %>%
  ggplot(aes(x = "", y = n, fill = x)) + 
  geom_col(width = .10) + 
  #  scale_fill_manual(values = c("black", "#039dfc", "yellow")) + 
  coord_flip() +
  theme_void() +
  geom_text(
    aes(label = paste(n)), 
    position = position_stack(vjust = 0.4),
    hjust = 0, 
    vjust = .5,
    size = 7, fontface = "bold", family = "Roboto Condensed"
  ) +
  geom_text(
    aes(label = paste(x)), 
    position = position_stack(vjust = 0.5),
    hjust = 0.4, 
    vjust = -3.5,
    size = 5, fontface = "bold", family = "Roboto Condensed"
  ) +
  guides(fill="none")
