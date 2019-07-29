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

make_map = function(routes, coloring_select = "Her rota ayrı renk") {
	routes$col_per_route = 1:nrow(routes)
	routes$col_per_smi_wkd = dplyr::group_indices(routes, salesman_id, week_day)

	#routes$col_per_smi = dplyr::group_indices(routes, salesman_id)
	routes$col_per_smi = dplyr::ungroup(routes) %>%
		dplyr::group_by(salesman_id) %>%
		dplyr::group_indices(salesman_id)

	orig = routes[1, ] %>%
		dplyr::select(lng = from_lng, lat = from_lat)
	m <- leaflet::leaflet(width="100%") %>% 
		leaflet::addTiles() %>%
		leaflet::addAwesomeMarkers(lng=orig$lng, lat=orig$lat)

	if (coloring_select == "Her rota ayrı renk") { 
		r1 = routes %>%
			left_join(colors, by = c("col_per_route" = "color_id"))
	} else if (coloring_select == "Her gün x satıcı ayrı renk") { 
		r1 = routes %>%
			left_join(colors, by = c("col_per_smi_wkd" = "color_id"))
	} else if (coloring_select == "Her satıcı ayrı renk") {  
		r1 = routes %>%
			left_join(colors, by = c("col_per_smi" = "color_id"))
	}
	m = make_map_with_markers(m, r1)
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
		#ph = path(rt)
		ph = routes$geometry[sqn]
		icon_num = leaflet::makeAwesomeIcon(text = routes$next_sequence_no[sqn], markerColor = routes$color[sqn])
		map = map %>% 
			leaflet::addPolylines(data = ph
				, popup=glue::glue( "
						from: {routes$customer_name[sqn]} - to: {routes$to_customer_name[sqn]} 
						<br> salesman: {routes$salesman_id[sqn]} - day: {routes$week_day[sqn]} 
						<br> sequence_no: {routes$next_sequence_no[sqn]}")
				, label = route_label(rt, routes, sqn, dest)
				, color = routes$color[sqn]
				, opacity=1
				, weight = 3
			) %>%
			leaflet::addAwesomeMarkers( 
				layerId = as.character(dest$to_point_id)
				, lng=dest$lng
				, lat=dest$lat
				, icon = icon_num
				, popup=glue::glue( "
						{routes$to_customer_name[sqn]} 
						<br> salesman: {routes$salesman_id[sqn]} - day: {routes$week_day[sqn]} 
						<br> sequence_no: {routes$next_sequence_no[sqn]}")
				, label = glue::glue("{routes$next_sequence_no[sqn]} - {routes$to_customer_name[sqn]} ")
			)
	}
	return(map)
}

route_label = function(route, routes, sqn, dest) {
	s <- route$routes[[1]]$duration
	kms <- round(route$routes[[1]]$distance/1000, 1)
	#result = glue::glue("{s%/%60}m {round(s%%60, 0)}s {kms}km")
	result = glue::glue("{kms}km - {routes$next_sequence_no[sqn]} - {routes$to_customer_name[sqn]} ")
	return(result)
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
	#twc = readr::read_tsv(glue::glue("{PEYMAN_PROJECT_DIR}/pvrp_data/out/{plan_name}/trips_with_route_geometry.tsv")) 
	twc = readr::read_csv(glue::glue("{PEYMAN_PROJECT_DIR}/pvrp_data/out/{plan_name}/trips_with_route_geometry.csv")) %>%
		dplyr::mutate(geometry = sf::st_as_sfc(geometry_wkt)) %>%
		sf::st_sf()
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
			, to_customer_id
			, to_customer_name
			, geometry
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

