library(dplyr)
library(readr)
library(curl)
library(sf)
library(googlePolylines)

c3 = st_read("trips_with_geometry04.csv") 

gwkt = c3$geometry_wkt[1]
sfc0 = st_as_sfc(gwkt)

m <- leaflet(width="100%") %>% 
  addTiles()  %>% 
  addPolylines(data = sfg0[[1]], color = "#AC0505", opacity=1, weight = 3) 
m
