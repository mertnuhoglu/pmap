library(dplyr)
library(readr)
library(curl)
library(sf)
library(googlePolylines)

c0 = readr::read_tsv("trips_with_route_geometry.tsv") %>%
	dplyr::select(from_point_id, to_point_id, from_lng, from_lat, to_lng, to_lat, route_geometry) %>%
	dplyr::mutate(decoded = googlePolylines::decode(route_geometry))

sfg06 = lapply(c0$decoded, function(decoded_df) {
	decoded_df %>%
		dplyr::select(lon, lat) %>%
		data.matrix() %>%
		st_linestring() %>%
		st_sfc() %>%
		st_sf()
}) %>% do.call(rbind, .)

c1 = c0 %>%
	dplyr::mutate(geometry = sfg06$geometry) %>%
	st_sf() %>%
	dplyr::select(-route_geometry, -decoded)

st_write(c1, "trips_with_geometry01.csv")
  ##> from_point_id,to_point_id,from_lng,from_lat,to_lng,to_lat
  ##> 1,1371,29.208498,40.890795,29.13966,40.99401
  ##> 1371,2328,29.13966,40.99401,29.134052,40.993877

c2 = c1 %>%
	dplyr::mutate(geometry_wkt = st_as_text(geometry))
readr::write_tsv(c2, "trips_with_geometry03.tsv")
st_write(c2, "trips_with_geometry04.csv")

