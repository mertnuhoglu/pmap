library(shiny)
library(leaflet)
source("get_routes_ex31.R")
source("pvrp.R")

# name mappings:
# sequence_no = sqn
# salesman_id = smi
# salesman_no = smn

routes_all = get_routes_verbal()
salesman = get_salesman()
sqn_selected = 0
smn_selected = 1
smi_selected = 7
wkd_selected = 0
sqn_init = get_routes_by_smi_wkd(routes_all, smi_selected, wkd_selected)
smi_init = salesman$salesman_id
wkd_init = routes_all$week_day %>% unique %>% sort

ui = fluidPage(
  title = "Rotalar arasında navigasyon",
  sidebarLayout(
    sidebarPanel(
			actionButton("sqn_prev", "Önceki")
			, actionButton("sqn_next", "Sonraki")
      , selectInput("sqn_select", "Rota sırası", choices = sqn_init, selected = sqn_selected, selectize = F)
			, actionButton("smn_prev", "Önceki Satıcı")
			, actionButton("smn_next", "Sonraki Satıcı")
      , selectInput("smi_select", "Satıcı", choices = smi_init, selected = smi_selected, selectize = F)
			, actionButton("wkd_prev", "Önceki Gün")
			, actionButton("wkd_next", "Sonraki Gün")
      , selectInput("wkd_select", "Gün", choices = wkd_init, selected = wkd_selected, selectize = F)
		)
		, mainPanel(
			textOutput("sqn_out")
			, textOutput("smn_out")
      , tableOutput("wkd_out")
      , tableOutput("routes")
			, leafletOutput("map")
    )
	)
)

server = function(input, output, session) {
	state = reactiveValues(sqn = sqn_selected, routes = get_routes_by_smi_wkd(routes_all, smi_selected, wkd_selected), smn = smn_selected, wkd = wkd_selected, smi = smi_selected)
	observeEvent(input$sqn_next, { state$sqn = state$sqn + 1 })
	observeEvent(input$sqn_prev, { state$sqn = state$sqn - 1 })
	observeEvent(input$sqn_select, { state$sqn = as.numeric(input$sqn_select) })
	observe({
		updateSelectInput(session, "sqn_select",
			choices = state$routes$sequence_no
			, selected = state$sqn
	)})
	observe({
		updateSelectInput(session, "smi_select",
			selected = state$smi
	)})
	observe({
		updateSelectInput(session, "wkd_select",
			selected = state$wkd
	)})
  output$sqn_out = renderText({ state$sqn })
  output$smn_out = renderText({ state$smn })
  output$wkd_out = renderText({ state$wkd })
	refresh_salesman_no = function() {
		state$smi = (dplyr::filter(salesman, salesman_no == state$smn))$salesman_id
		refresh_salesman_routes()
	}
	refresh_salesman_id = function() {
		state$smn = (dplyr::filter(salesman, salesman_id == state$smi))$salesman_no
		refresh_salesman_routes()
	}
	refresh_salesman_routes = function() {
		state$routes = get_routes_by_smi_wkd(routes_all, state$smi, state$wkd)
		state$sqn = 0
		return(state)
	}
	observeEvent(input$smn_next, {
		state$smn = state$smn + 1
		refresh_salesman_no()
	})
	observeEvent(input$smn_prev, {
		state$smn = state$smn - 1
		refresh_salesman_no()
	})
	observeEvent(input$smi_select, {
		state$smi = as.numeric(input$smi_select)
		refresh_salesman_id()
	})
	observeEvent(input$wkd_next, {
		state$wkd = state$wkd + 1
		refresh_salesman_routes()
	})
	observeEvent(input$wkd_prev, {
		state$wkd = state$wkd - 1
		refresh_salesman_routes()
	})
	observeEvent(input$wkd_select, {
		state$wkd = as.numeric(input$wkd_select)
		refresh_salesman_routes()
	})
  routeS = reactive({ get_route_upto_sequence_no(state$routes, state$sqn) })
  output$routes = renderTable({ routeS() })
  output$map = renderLeaflet({ get_routes_all(routeS()) })
}

runApp(shinyApp(ui, server), host="0.0.0.0",port=5050)
