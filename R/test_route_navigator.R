library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)

routes_all = get_routes_verbal()
salesman = get_salesman()
init_sqn_selected = 0
init_smi_selected = 7
init_gun_selected = days$gun[1]
init_wkd_selected = gun2week_day(init_gun_selected)
init_sqn_choices = get_routes_by_smi_wkd(routes_all, init_smi_selected, init_wkd_selected)
init_smi_choices = salesman$salesman_id
init_gun_choices = days$gun

state = list(
	sqn = init_sqn_selected
	, routes = get_routes_by_smi_wkd(routes_all, init_smi_selected, init_wkd_selected)
	, gun = init_gun_selected
	, smi = init_smi_selected
)
state$routeSS = get_route_upto_sequence_no(state$routes, state$sqn)
state$map = make_map(state$routeSS)

