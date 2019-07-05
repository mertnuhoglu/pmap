library(dplyr)
library(readr)
library(curl)
library(sf)
library(googlePolylines)

c0 = readr::read_tsv("../trips_with_route_geometry.tsv") %>%
	dplyr::select(from_point_id, to_point_id, from_lng, from_lat, to_lng, to_lat, route_geometry) %>%
	dplyr::mutate(decoded = googlePolylines::decode(route_geometry))

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
  ##>                          geometry
  ##> 1  LINESTRING (29.20862 40.890...
  ##> 2  LINESTRING (29.13966 40.993...

c2 = c0
c2$geometry = sfg06$geometry
c3 = st_sf(c2) %>%
	dplyr::select(-route_geometry, -decoded)
  ##> Simple feature collection with 3000 features and 9 fields
  ##>    from_point_id to_point_id from_lng from_lat to_lng to_lat                                                                                  geometry
  ##>  1             1        1371     29.2     40.9   29.1   41.0 (29.20862 40.89088, 29.20844 40.89102, 29.20823 40.89119, 29.20798 40.89131, 29.20778 ...


