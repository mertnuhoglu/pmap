library(shiny)
library(leaflet)
source("get_routes.R")
source("pvrp.R")

# name mappings:
# sequence_no = sqn
# salesman_id = smi

routes = get_routes_verbal()

ui = fluidPage(
  title = "Rotalar arasında navigasyon",
  sidebarLayout(
    sidebarPanel(
			actionButton("sqn_prev", "Önceki")
			, actionButton("sqn_next", "Sonraki")
      , selectInput("sqn_select", "Rota sırası", choices = routes$sequence_no, selected = "0", selectize = F)
			, actionButton("smi_prev", "Önceki Satıcı")
			, actionButton("smi_next", "Sonraki Satıcı")
      , selectInput("smi_select", "Satıcı", choices = get_salesman()$salesman_id %>% unique, selected = "7", selectize = F)
		)
		, mainPanel(
			textOutput("seq_no")
      , tableOutput("routes")
			, leafletOutput("map")
    )
	)
)

server = function(input, output, session) {
	state = reactiveValues(sqn = 0) 
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
			selected = state$sqn
	)})
  output$seq_no = renderText({
		state$sqn
  })
  route_input = reactive({
		get_route_for_sequence_no(routes, state$sqn)
  })
  output$routes = renderTable({
		route_input()
  })
  output$map = renderLeaflet({
		get_route_geometry_bw_points(route_input())
  })
}

runApp(shinyApp(ui, server), host="0.0.0.0",port=5050)
