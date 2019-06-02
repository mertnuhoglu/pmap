library("leaflet")
library("rjson")
library("bitops")
library("sp")
source("decode.R")
library("glue")

osrm_server = Sys.getenv("OSRM_SERVER")

get_routes_all = function(routes) {
	cs = routes
	no_routes = nrow(cs) - 1
	pal <- colorNumeric(c('#2e86c1' , '#5dade2' , '#8e44ad' , '#9b59b6' , '#a93226' , '#ec7063'), 1:6)
	col = rep(pal(1:6), times = 1 + (no_routes / 6))

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

get_route_upto_sequence_no = function(routes, seq_no) {
	routes %>%
		dplyr::filter(sequence_no <= seq_no + 1) 
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
		addPolylines(data = ph, label = route_label(rt), color = "tomato", opacity=1, weight = 3) %>%
		addMarkers(lng=p1$lng, lat=p1$lat, popup=glue("Market {i}"), label = glue("{i}")) %>%
		addMarkers(lng=p2$lng, lat=p2$lat, popup=glue("Market {i+1}"), label = glue("{i+1}")) 
	return(m)
}

get_route_geometry_bw_points = function(routes) {
	get_route_geometry(routes, 1)
}

get_routes_verbal = function() {
	twc = readr::read_tsv("~/projects/itr/peyman/pvrp/out/trips_with_costs.tsv")
  #twc = readr::read_tsv("~/pvrp/out/trips_with_costs.tsv")
	routes = twc %>%
		dplyr::select(
			salesman_id
			, week_day
			, lat = from_lat
			, lng = from_lng
			, sequence_no
		)
	return(routes)
}

get_routes_by_smi_wkd = function(routes, smi, wkd) {
	rt01 = routes %>%
		dplyr::filter(salesman_id == smi & week_day == wkd) 
	depot = rt01[1, ]
	cs = dplyr::bind_rows(rt01, depot)

	return(cs)
}
