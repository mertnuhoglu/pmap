library(dplyr)
library(readr)
library(curl)
library(sf)
library(googlePolylines)

c0 = readr::read_tsv("../trips_with_route_geometry.tsv") %>%
	dplyr::select(from_point_id, to_point_id, from_lng, from_lat, to_lng, to_lat, route_geometry)

p0 = googlePolylines::decode(c0$route_geometry[1])
p1 = p0[[1]] %>%
	dplyr::select(lon, lat) %>%
	data.matrix()
sfc01 = st_linestring(p1) %>%
	st_sfc()

c1 = c0[1, ]
c1$geom = sfc01
c2 = st_sf(c1)
  ##> Simple feature collection with 1 feature and 7 fields
  ##> geometry type:  LINESTRING
  ##> dimension:      XY
  ##> bbox:           xmin: 29.11196 ymin: 40.89088 xmax: 29.2125 ymax: 40.99405
  ##> epsg (SRID):    NA
  ##> proj4string:    NA
  ##> # A tibble: 1 x 8
  ##>   from_point_id to_point_id from_lng from_lat to_lng to_lat route_geometry                                                                        geom
  ##>           <dbl>       <dbl>    <dbl>    <dbl>  <dbl>  <dbl> <chr>                                                                         <LINESTRING>
  ##> 1             1        1371     29.2     40.9   29.1   41.0 "_oqxF{xgqD[b@a@h@Wp@Qf@Uz@ETCPCPiADeI\\eN`AQ@K… (29.20862 40.89088, 29.20844 40.89102, 2…
