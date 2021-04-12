library("leaflet")
library("rjson")
library("bitops")
library("sp")
source("decode.R")
library("glue")

osrm_server = Sys.getenv("OSRM_SERVER")

twc = readr::read_tsv("~/projects/itr/fmcgvrp/pvrp/out/trips_with_costs.tsv")
#twc = readr::read_tsv("~/pvrp/out/trips_with_costs.tsv")

rt07 = twc %>%
	dplyr::filter(salesman_id == 7 & week_day == 0) %>%
	dplyr::select(
		lat = from_lat
		, lng = from_lng
		, sequence_no
	)
depot = rt07[1, ]
cs = dplyr::bind_rows(rt07, depot)

no_routes = nrow(cs) - 1
pal <- colorNumeric(c("red", "green", "blue"), 1:no_routes)
col = pal(1:no_routes)


get_routes = function() {
	m <- leaflet(width="100%") %>% 
		addTiles()  

	for (i in 1:no_routes) {
		p1 = cs[i, ]
		p2 = cs[i+1, ]
		rt = route(p1, p2)
		ph = path(rt)
		m = m %>% 
			addPolylines(data = ph, label = route_label(rt), color = col[i], opacity=1, weight = 3) %>%
			addMarkers(lng=p1$lng, lat=p1$lat, popup=glue("Market {i}"), label = glue("{i}")) 
	}
	m = m %>%
		addMarkers(lng=p2$lng, lat=p2$lat, popup=glue("Market {i+1}"), label = glue("{i+1}")) 
	return(m)
}

get_route_for_sequence_no = function(routes, sequence_no) {
	sq = c(sequence_no, sequence_no + 1)
	routes %>%
		dplyr::filter(sequence_no %in% sq) 
}

get_route_geometry = function(routes, sequence_no) {
	i = sequence_no
	p1 = routes[i, ]
	p2 = routes[i+1, ]
	rt = route(p1, p2)
	ph = path(rt)
	m <- leaflet(width="100%") %>% 
		addTiles() %>%
		addPolylines(data = ph, label = route_label(rt), color = col[i], opacity=1, weight = 3) %>%
		addMarkers(lng=p1$lng, lat=p1$lat, popup=glue("Market {i}"), label = glue("{i}")) %>%
		addMarkers(lng=p2$lng, lat=p2$lat, popup=glue("Market {i+1}"), label = glue("{i+1}")) 
	return(m)
}

get_route_geometry_bw_points = function(routes) {
	get_route_geometry(routes, 1)
}

get_routes_verbal = function() {
	return(cs)
}
