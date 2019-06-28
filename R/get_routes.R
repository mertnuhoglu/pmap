library("leaflet")
library("rjson")
library("bitops")
library("sp")
library("glue")

osrm_server = Sys.getenv("OSRM_SERVER")

remove_markers = function(map, routes) {
	route_groups = routes %>%
		dplyr::group_by(salesman_id, week_day) %>%
		dplyr::group_split()

	for (gr in seq_along(route_groups)) {
		route_group = route_groups[[gr]]
		for (sqn in seq_len(nrow(routes))) {
			dest = routes[sqn, ] %>%
				dplyr::select(lng = to_lng, lat = to_lat, customer_name, to_point_id)
			map = map %>%
				removeMarker( layerId = as.character(dest$to_point_id) )
		}
	}
	return(map)
}
make_map = function(routes, is_multiple_color_route = T) {
	route_groups = routes %>%
		dplyr::group_by(salesman_id, week_day) %>%
		dplyr::group_split()

	orig = routes[1, ] %>%
		dplyr::select(lng = from_lng, lat = from_lat)
	m <- leaflet::leaflet(width="100%") %>% 
		leaflet::addTiles() %>%
		leaflet::addAwesomeMarkers(lng=orig$lng, lat=orig$lat)

	pal = c("red", "purple", "darkblue", "orange", "cadetblue", "green", "darkred", "pink", "gray", "darkgreen", "black")
	for (gr in seq_along(route_groups)) {
		route_group = route_groups[[gr]]
		if (is_multiple_color_route) {
			col = rep(pal, times = 1 + (nrow(route_group) / length(pal)))
		} else {
			col = rep(pal[gr], times = nrow(route_group))
		}
		col = col[1:nrow(route_group)]
		route_group$color = col
		m = make_map_with_markers(m, route_group)
	}
	return(m)
}
make_map_with_markers = function(map, route_group) {
	routes = route_group

	for (sqn in seq_len(nrow(routes))) {
		orig = routes[sqn, ] %>%
			dplyr::select(lng = from_lng, lat = from_lat, customer_name)
		dest = routes[sqn, ] %>%
			dplyr::select(lng = to_lng, lat = to_lat, customer_name, to_point_id)
		rt = route(orig, dest)
		ph = path(rt)
		icon_num = leaflet::makeAwesomeIcon(text = sqn, markerColor = route_group$color[sqn])
		map = map %>% 
			leaflet::addPolylines(data = ph, label = route_label(rt), color = route_group$color[sqn], opacity=1, weight = 3) %>%
			leaflet::addAwesomeMarkers( layerId = as.character(dest$to_point_id), lng=dest$lng, lat=dest$lat, icon = icon_num, popup=dest$customer_name, label = glue::glue("{sqn} - {dest$customer_name}")) 
	}
	return(map)
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

get_routes_verbal = function(plan_name) {
	twc = readr::read_tsv(glue::glue("{PEYMAN_PROJECT_DIR}/pvrp_data/out/{plan_name}/trips_with_costs.tsv")) 
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
			, customer_name
		) %>%
		dplyr::group_by(salesman_id, week_day) %>%
		dplyr::mutate(
			prev_sequence_no = dplyr::lag(sequence_no, default = dplyr::last(sequence_no))
			, next_sequence_no = dplyr::lead(sequence_no, default = dplyr::first(sequence_no))
		) 
	return(routes)
}

get_routes_by_smi_wkd = function(routes, smi, wkd) {
	rt01 = routes %>%
		dplyr::filter(salesman_id %in% smi & week_day %in% wkd) 

	return(rt01)
}

