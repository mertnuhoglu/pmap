library("leaflet")
library("rjson")
library("bitops")
library("sp")
source("decode.R")
library("glue")

osrm_server = Sys.getenv("OSRM_SERVER")

make_map = function(routes) {
	pal = c("red", "purple", "darkblue", "orange", "cadetblue", "green", "darkred", "pink", "gray", "darkgreen", "black")
	#pal = (colorNumeric(c('#2e86c1' , '#5dade2' , '#8e44ad' , '#9b59b6' , '#a93226' , '#ec7063'), 1:6))(1:6)
	col = rep(pal, times = 1 + (nrow(routes) / length(pal)))

	orig = routes[1, ] %>%
		dplyr::select(lng = from_lng, lat = from_lat)
	m <- leaflet(width="100%") %>% 
		addTiles() %>%
		addAwesomeMarkers(lng=orig$lng, lat=orig$lat)

	for (sqn in 1:nrow(routes)) {
		orig = routes[sqn, ] %>%
			dplyr::select(lng = from_lng, lat = from_lat)
		dest = routes[sqn, ] %>%
			dplyr::select(lng = to_lng, lat = to_lat)
		rt = route(orig, dest)
		ph = path(rt)
		icon_num = makeAwesomeIcon(text = sqn, markerColor = col[sqn])
		m = m %>% 
			addPolylines(data = ph, label = route_label(rt), color = col[sqn], opacity=1, weight = 3) %>%
			addAwesomeMarkers(lng=dest$lng, lat=dest$lat, icon = icon_num, popup=glue("Market {sqn}"), label = glue("{sqn}")) 
	}
	return(m)
}

get_route_upto_sequence_no = function(routes, sqn) {
	routes %>%
		dplyr::filter(sequence_no <= sqn) 
}

get_route_for_sequence_no = function(routes, sequence_no) {
	sqns = c(sequence_no, sequence_no + 1)
	routes %>%
		dplyr::filter(sequence_no %in% sqns) 
}

get_routes_verbal = function() {
	twc = readr::read_tsv(glue::glue("{PEYMAN_PROJECT_DIR}/pvrp/out/trips_with_costs.tsv")) 
	routes = twc %>%
		dplyr::select(
			salesman_id
			, week_day
			, from_point_id
			, to_point_id
			, from_lat
			, from_lng
			, to_lat
			, to_lng
			, sequence_no
		)
	return(routes)
}

get_routes_by_smi_wkd = function(routes, smi, wkd) {
	rt01 = routes %>%
		dplyr::filter(salesman_id == smi & week_day == wkd) 

	return(rt01)
}

