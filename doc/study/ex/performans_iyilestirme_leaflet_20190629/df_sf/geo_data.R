# from ~/codes/rr/intro-to-r/gis-with-r-intro.R

library(tidyverse)
library(sp)
library(sf)
library(rnaturalearth)

# Load the data
letters <- read_csv("~/codes/rr/intro-to-r/data/correspondence-data-1585.csv")
locations <- read_csv("~/codes/rr/intro-to-r/data/locations.csv")

########################
## Preparing the data ##
########################

# Letters per source
sources <- letters %>% 
  group_by(source) %>% 
  count() %>% 
  rename(place = source) %>% 
  add_column(type = "source") %>% 
  ungroup()

# Letters per destination
destinations <- letters %>% 
  group_by(destination) %>% 
  count() %>% 
  rename(place = destination) %>% 
  add_column(type = "destination") %>% 
  ungroup()

# Bind the rows of the two data frames
# and change type column to factor
letters_data <- rbind(sources, destinations) %>% 
  mutate(type = as_factor(type))

# Join letters_data to locations
geo_data <- left_join(letters_data, locations, by = "place")


