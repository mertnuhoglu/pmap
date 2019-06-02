library(shiny)
library(leaflet)
source("get_routes_ex28d.R")
source("pvrp.R")

# name mappings:
# sequence_no = sqn
# salesman_id = smi
# salesman_no = smn

routes_all = get_routes_verbal()
salesman = get_salesman()
smi_selected = 7
smi_init = salesman$salesman_id
sqn_selected = 0
sqn_init = get_routes_by_smi_wkd(routes_all, smi_selected, sqn_selected)
smn_selected = 1

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
		)
		, mainPanel(
			textOutput("sqn_out")
			, textOutput("smn_out")
      , tableOutput("routes")
			, leafletOutput("map")
    )
	)
)

server = function(input, output, session) {
	state = reactiveValues(sqn = sqn_selected, routes = get_routes_by_smi_wkd(routes_all, smi_selected, sqn_selected), smn = smn_selected)
	observeEvent(input$sqn_next, {
		state$sqn = state$sqn + 1
	})
	observeEvent(input$sqn_prev, {
		state$sqn = state$sqn - 1
	})
	observeEvent(input$sqn_select, {
		state$sqn = as.numeric(input$sqn_select)
	})
	observe({
		updateSelectInput(session, "sqn_select",
			choices = state$routes$sequence_no
			, selected = state$sqn
	)})
  output$sqn_out = renderText({
		state$sqn
  })
  output$smn_out = renderText({
		state$smn
  })
	refresh_salesman = function() {
		state$smi = (dplyr::filter(salesman, salesman_no == state$smn))$salesman_id
		state$routes = get_routes_by_smi_wkd(routes_all, state$smi, sqn_selected)
		state$sqn = 0
		return(state)
	}
	observeEvent(input$smn_next, {
		state$smn = state$smn + 1
		refresh_salesman()
	})
	observeEvent(input$smn_prev, {
		state$smn = state$smn - 1
		state$smi = (dplyr::filter(salesman, salesman_no == state$smn))$salesman_id
		state$routes = get_routes_by_smi_wkd(routes_all, state$smi, sqn_selected)
		state$sqn = 0
	})
	observeEvent(input$smi_select, {
		state$smi = as.numeric(input$smi_select)
		state$smn = (dplyr::filter(salesman, salesman_id == state$smi))$salesman_no
		state$routes = get_routes_by_smi_wkd(routes_all, state$smi, sqn_selected)
		state$sqn = 0
	})
  route_input = reactive({
		get_route_for_sequence_no(state$routes, state$sqn)
  })
  output$routes = renderTable({
		route_input()
  })
  output$map = renderLeaflet({
		get_route_geometry_bw_points(route_input())
  })
}

runApp(shinyApp(ui, server), host="0.0.0.0",port=5050)
