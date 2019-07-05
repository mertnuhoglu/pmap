library(dplyr)
library(leaflet)
library(readr)
library(curl)
library(sf)
library(googlePolylines)

c3 = st_read("trips_with_geometry04.csv") %>%
	dplyr::mutate(geom = st_as_sfc(geometry_wkt)) %>%
	st_sf()

m <- leaflet(width="100%") %>% 
  addTiles()  %>% 
  addPolylines(data = c3$geom[1], color = "#AC0505", opacity=1, weight = 3) 
m
