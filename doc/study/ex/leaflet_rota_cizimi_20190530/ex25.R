library(shiny)
library(leaflet)
source("get_routes.R")

routes = get_routes_verbal()

ui = fluidPage(
  title = "Rotalar arasında navigasyon",
  sidebarLayout(
    sidebarPanel(
			actionButton("prev_route", "Önceki")
			, actionButton("next_route", "Sonraki")
		)
		, mainPanel(
			textOutput("seq_no")
      , tableOutput("routes")
			, leafletOutput("map")
    )
	)
)

server = function(input, output) {
	seq_counter <- reactiveValues(seq_value = 0) 
	observeEvent(input$next_route, {
		seq_counter$seq_value <- seq_counter$seq_value + 1
	})
	observeEvent(input$prev_route, {
		seq_counter$seq_value <- seq_counter$seq_value - 1
	})
  output$seq_no <- renderText({
		seq_counter$seq_value
  })
  route_input <- reactive({
		get_route_for_sequence_no(routes, seq_counter$seq_value)
  })
  output$routes <- renderTable({
		route_input()
  })
  output$map <- renderLeaflet({
		get_route_geometry_bw_points(route_input())
  })
}

runApp(shinyApp(ui, server), host="0.0.0.0",port=5050)
