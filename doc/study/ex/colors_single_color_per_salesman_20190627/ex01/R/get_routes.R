ex01_fun = function() {
	print("hello")
}

get_routes_verbal = function(plan_name) {
	FMCGVRP_PROJECT_DIR = Sys.getenv("FMCGVRP_PROJECT_DIR")
	twc = readr::read_tsv(glue::glue("{FMCGVRP_PROJECT_DIR}/pvrp_data/out/{plan_name}/trips_with_costs.tsv")) 
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
