library(shiny)
library(leaflet)
source("get_routes_ex28d.R")
source("pvrp.R")

# name mappings:
# sequence_no = sqn
# salesman_id = smi

routes_all = get_routes_verbal()
smi_selected = 7
smi_init = get_salesman()$salesman_id %>% unique
sqn_selected = 0
sqn_init = get_routes_by_smi_wkd(routes_all, smi_selected, sqn_selected)

ui = fluidPage(
  title = "Rotalar arasında navigasyon",
  sidebarLayout(
    sidebarPanel(
			actionButton("sqn_prev", "Önceki")
			, actionButton("sqn_next", "Sonraki")
      , selectInput("sqn_select", "Rota sırası", choices = sqn_init, selected = sqn_selected, selectize = F)
			, actionButton("smi_prev", "Önceki Satıcı")
			, actionButton("smi_next", "Sonraki Satıcı")
      , selectInput("smi_select", "Satıcı", choices = smi_init, selected = smi_selected, selectize = F)
		)
		, mainPanel(
			textOutput("seq_no")
      , tableOutput("routes")
			, leafletOutput("map")
    )
	)
)

server = function(input, output, session) {
	state = reactiveValues(sqn = sqn_selected, routes = get_routes_by_smi_wkd(routes_all, smi_selected, sqn_selected))
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
  output$seq_no = renderText({
		state$sqn
  })
	observeEvent(input$smi_next, {
		state$smi = state$smi + 1
	})
	observeEvent(input$smi_prev, {
		state$smi = state$smi - 1
	})
	observeEvent(input$smi_select, {
		state$smi = as.numeric(input$smi_select)
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
