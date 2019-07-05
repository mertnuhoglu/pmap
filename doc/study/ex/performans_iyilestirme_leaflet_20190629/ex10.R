library(dplyr)
library(readr)
library(curl)
source("decode.R")

c0 = readr::read_tsv("trips_with_route_geometry.tsv") %>%
	dplyr::select(from_point_id, to_point_id, from_lng, from_lat, to_lng, to_lat, route_geometry)

p0 = decode_sf(c0$route_geometry[1], multiplier=1e5)
str(p0)
  ##> Classes ‘sf’ and 'data.frame':  1 obs. of  1 variable:...
