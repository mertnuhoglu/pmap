library(dplyr)
library(readr)
library(curl)
source("decode.R")

c0 = readr::read_tsv("trips_with_costs.tsv") %>%
	dplyr::select(from_point_id, to_point_id, from_lng, from_lat, to_lng, to_lat)

osrm_server = Sys.getenv("OSRM_SERVER")

c1 = c0 %>%
	dplyr::mutate(route_url = glue::glue("http://{osrm_server}/route/v1/driving/{from_lng},{from_lat};{to_lng},{to_lat}?overview=full"))

url = c1$route_url[1]
rt = rjson::fromJSON(file=url)
ph = path(rt)
route_label(rt)

c2 = c1[1:3, ]

test = function(url) {

}
c3 = c2 %>%
	dplyr::mutate(route_geometry = test(file = route_url))

