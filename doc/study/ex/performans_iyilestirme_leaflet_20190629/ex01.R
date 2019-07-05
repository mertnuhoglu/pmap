library(dplyr)
library(readr)

c0 = readr::read_tsv("trips_with_costs.tsv") %>%
	dplyr::select(from_point_id, to_point_id, from_lng, from_lat, to_lng, to_lat)

osrm_server = Sys.getenv("OSRM_SERVER")

c1 = c0 %>%
	dplyr::mutate(route_url = glue::glue("http://{osrm_server}/route/v1/driving/{orig$lng},{orig$lat};{dest$lng},{dest$lat}?overview=full"))

