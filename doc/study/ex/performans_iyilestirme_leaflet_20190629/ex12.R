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

c2 = c1 %>%
	dplyr::mutate(geometry_wkt = st_as_text(geometry))

st_write(c2, "trips_with_geometry04.csv")

c3 = st_read("trips_with_geometry04.csv") %>%
	dplyr::mutate(geom = st_as_sfc(geometry_wkt)) %>%
	st_sf()

