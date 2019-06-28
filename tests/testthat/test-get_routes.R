library(dplyr)

context("test-get_routes")

init_state = function() {
	v = init_vars()

	state = list(
		routes_all = v$init_routes_all
		, sqn = v$init_sqn_selected
		, routes = get_routes_by_smi_wkd(v$init_routes_all, v$init_smi_selected, v$init_wkd_selected)
		, gun = v$init_gun_selected
		, smi = v$init_smi_selected
	)
	#state$routeSS = get_route_upto_sequence_no(state$routes, state$sqn)
	#state$map = make_map(state$routeSS)
	return(state)
}

test_that("get_routes setup", {
	skip_on_cran()

	state = init_state()

  expect_equal(2 * 2, 4)
})

test_that("make_map arguments", {
	# map = make_map(state$routeSS, coloring_select)
	state = init_state()
	is_multiple_route_sets_selected = F
	if (is_multiple_route_sets_selected) {
		state$routeSS = state$routes
	} else {
		state$routeSS = get_route_upto_sequence_no(state$routes, state$sqn)
	}
	routes = state$routeSS
  expect_equal(2 * 2, 4)
})

test_that("debug state$routes_all", {
	# map = make_map(state$routeSS, coloring_select)
	state = init_state()
	state$routes_all
	state$routes_all$salesman_id %>% unique()
  expect_equal(2 * 2, 4)
})

test_that("make_map called with multiple salesman and weekdays", {
	# map = make_map(state$routeSS, coloring_select)
	state = init_state()
	state$routes = get_routes_by_smi_wkd(v$init_routes_all, c(7,12), v$init_wkd_selected)
	state$routeSS = state$routes
	routes = state$routeSS
	coloring_select = "Her rota ayrı renk"

	# make_map implementation
	route_groups = routes %>%
		dplyr::group_by(salesman_id, week_day) %>%
		dplyr::group_split()
	orig = routes[1, ] %>%
		dplyr::select(lng = from_lng, lat = from_lat)
	m <- leaflet(width="100%") %>% 
		addTiles() %>%
		addAwesomeMarkers(lng=orig$lng, lat=orig$lat)

	pal = c("red", "purple", "darkblue", "orange", "cadetblue", "green", "darkred", "pink", "gray", "darkgreen", "black")
	gr = 1
	route_group = route_groups[[gr]]

	m = make_map_with_markers(m, route_group, col)
  expect_equal(2 * 2, 4)
})
