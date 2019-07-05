library(dplyr)
library(readr)
library(curl)
library(sf)
library(googlePolylines)

c0 = readr::read_tsv("../trips_with_route_geometry.tsv") %>%
	dplyr::select(from_point_id, to_point_id, from_lng, from_lat, to_lng, to_lat, route_geometry) %>%
	dplyr::mutate(decoded = googlePolylines::decode(route_geometry))

c0$decoded %>% length
  ##> [1] 3000
c0 %>% nrow
  ##> [1] 3000
c0[1,]$decoded
  ##> [[1]]
  ##>          lat      lon
  ##> 1   40.89088 29.20862
  ##> 2   40.89102 29.20844

sfg01 = lapply(c0$decoded, function(decoded_df) {
	decoded_df %>%
		dplyr::select(lon, lat) %>%
		data.matrix() %>%
		st_linestring() 
})

sfg02 = unlist(sfg01)
class(sfg02)
  ##> [1] "numeric"

sfg03 = unlist(sfg01) %>%
	st_sfc() 
  ##> Error in vapply(lst, class, rep(NA_character_, 3)) :
  ##> class(sfg03)

sfg04 = do.call(rbind, sfg01)
class(sfg04)
  ##> [1] "matrix"

  ##> opt04: önce sf'ye çevir sonra rbind yap
sfg05 = lapply(c0$decoded, function(decoded_df) {
	decoded_df %>%
		dplyr::select(lon, lat) %>%
		data.matrix() %>%
		st_linestring() %>%
		st_sfc() %>%
		st_sf()
})
sfg06 = do.call(rbind, sfg05)
  ##> Simple feature collection with 3000 features and 0 fields
  ##> geometry type:  LINESTRING
  ##> dimension:      XY
  ##> bbox:           xmin: 29.00653 ymin: 40.75825 xmax: 29.85609 ymax: 41.22711
  ##> epsg (SRID):    NA
  ##> proj4string:    NA
  ##> First 10 features:
  ##>                          geometry
  ##> 1  LINESTRING (29.20862 40.890...
  ##> 2  LINESTRING (29.13966 40.993...

c1 = cbind(c0, sfg06)
  ##>                c0             sfg06
  ##> from_point_id  Numeric,3000   List,3000
  ##> to_point_id    Numeric,3000   List,3000
c2 = c0
c2$geometry = sfg06$geometry
c3 = st_sf(c2)
  ##> Simple feature collection with 3000 features and 9 fields
  ##> geometry type:  LINESTRING
  ##> dimension:      XY
  ##> bbox:           xmin: 29.00653 ymin: 40.75825 xmax: 29.85609 ymax: 41.22711
  ##> epsg (SRID):    NA
  ##> proj4string:    NA
  ##> # A tibble: 3,000 x 10
  ##>    from_point_id to_point_id from_lng from_lat to_lng to_lat route_geometry                       decoded   geom                              geometry
  ##>            <dbl>       <dbl>    <dbl>    <dbl>  <dbl>  <dbl> <chr>                                <list>    <list>                        <LINESTRING>
  ##>  1             1        1371     29.2     40.9   29.1   41.0 "_oqxF{xgqD[b@a@h@Wp@Qf@Uz@ETCPCPiA… <df[,2] … <LINE… (29.20862 40.89088, 29.20844 40.89…


