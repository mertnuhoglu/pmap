library(dplyr)
library(readr)
library(curl)
library(sf)
library(googlePolylines)

c0 = readr::read_tsv("../trips_with_route_geometry.tsv") %>%
	dplyr::select(from_point_id, to_point_id, from_lng, from_lat, to_lng, to_lat, route_geometry)

(p0 = googlePolylines::decode(c0$route_geometry[1]))
  ##> [[1]]
  ##>          lat      lon
  ##> 1   40.89088 29.20862
  ##> 2   40.89102 29.20844
class(p0)
  ##> [1] "list"
class(p0[[1]])
  ##> [1] "data.frame"

(m0 = data.matrix(p0[[1]]))
  ##>          lat      lon
  ##> 1   40.89088 29.20862
  ##> 2   40.89102 29.20844
class(m0)
  ##> [1] "matrix"

p1 = p0[[1]] %>%
	dplyr::select(lon, lat)
m1 = data.matrix(p1)
ls1 = st_linestring(m1)
(sfc01 = st_sfc(ls1))

c1 = c0[1, ]
c1$geom = sfc01
c2 = st_sf(c1)
