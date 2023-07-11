library(readr)
library(here)
library(stringdist)

census_table_2012 <- read_csv(here::here("data", "indicadores_municipios_cpv-2012_cod.csv"))
census_table_2012.imported <- census_table_2012

departments_by_num <- c("Chuquisaca", "La Paz", "Cochabamba", "Oruro", "Potosí", "Tarija", "Santa Cruz", "Beni", "Pando")


census_table_2012 <- census_table_2012 %>% 
                      mutate(cod.dep = as.numeric(str_sub(cod.mun, start=1, end=2))) %>% 
                      mutate(department = departments_by_num[cod.dep]) %>% 
                      dplyr::rename(municipality = departamento_y_municipio)

# Fix naming discrepancies in census table
census_table_2012 <- census_table_2012 %>%
  mutate(municipality = recode(municipality, "Entre Rios" = "Entre Ríos")) %>%
  mutate(municipality = recode(municipality, "Bolivar" = "Bolívar")) %>%
  mutate(municipality = recode(municipality, "Salinas de García Mendoza" = "Salinas de Garci Mendoza")) %>% # data table gets the name wrong
  mutate(municipality = recode(municipality, "Santa Ana de Yacuma" = "Santa Ana del Yacuma")) %>%
  mutate(municipality = recode(municipality, "Villa deSacaca" = "Sacaca")) %>%
  mutate(municipality = recode(municipality, "Independencia" = "Ayopaya")) %>% # Dual name for this municipality  
  mutate(municipality = recode(municipality, "San Ignacio" = "San Ignacio de Moxos")) 

census_population <- census_table_2012 %>% select(municipality, department, t_2001, t_2012)

# Counting deaths per municipality
de.municounts <- de %>%
  group_by(municipality, department) %>%
  dplyr::summarize(count = n()) %>%
  ungroup()


de.municounts.extended <- left_join(de.municounts, census_population, by = c('municipality' = 'municipality', 
                                                   'department' = 'department'))
antijoin_pop1 <- anti_join(de.municounts, census_population, by = c('municipality' = 'municipality', 
                                                                    'department' = 'department'))
missing_municipalities <- unique(antijoin_pop1$municipality)

antijoin_pop2 <- anti_join(census_population, de.municounts, by = c('municipality' = 'municipality', 
                                                                    'department' = 'department')) 
antijoin_pop2 <- antijoin_pop2 %>% arrange(desc(t_2001)) # in descending order of 2001 population

de.municounts.extended <- de.municounts.extended %>% mutate(one_per_pop_2001 = t_2001/count)


### Searching for unmentioned municipalities in the notes section…
municipalities_without_deaths <- unique(antijoin_pop2$municipality)
municipalities_without_deaths_search_string <- paste(municipalities_without_deaths, collapse ="|")
municipalities_without_deaths_search_string_head <- paste(head(municipalities_without_deaths, 249), collapse ="|")

de.narrative <- import_deaths_database(incl_narrative=TRUE)
narratives_to_review <- de.narrative %>% filter(str_detect(notes,municipalities_without_deaths_search_string_head) )
narratives_to_review <- narratives_to_review %>% mutate(notes = str_glue("{event_title}, {id_indiv}, {year}-{month}-{day}:\n Currently located in {municipality} municipality, {department}\n {notes} \n\n"))
narratives_to_review$notes


