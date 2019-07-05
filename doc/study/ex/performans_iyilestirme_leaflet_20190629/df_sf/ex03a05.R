library(dplyr)
library(readr)
library(curl)
library(sf)

c0 = readr::read_tsv("../trips_with_route_geometry.tsv") %>%
	dplyr::select(from_point_id, to_point_id, from_lng, from_lat, to_lng, to_lat, route_geometry)

st_as_sfc(c0$route_geometry[1])
  ##> OGR: Unsupported geometry type
  ##> Error in CPL_sfc_from_wkt(x) : OGR error

