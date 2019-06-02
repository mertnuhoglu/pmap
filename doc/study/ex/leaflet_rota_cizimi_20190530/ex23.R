library(shiny)
library(leaflet)
source("get_routes.R")

routes = get_routes_verbal()

ui = fluidPage(
  title = 'Select routes',
  sidebarLayout(
    sidebarPanel(
      selectInput(
        'sequence_no', 'Rota noyu seçin', choices = routes$sequence_no,
        selectize = FALSE
      )
		)

		, mainPanel(
      tableOutput("routes")
			, leafletOutput("map")
    )
	)
)

server = function(input, output) {
  seq_input <- reactive({
		as.numeric(input$sequence_no)
  })
  
  route_input <- reactive({
		get_route_for_sequence_no(routes, seq_input())
  })
  
  output$routes <- renderTable({
		route_input()
  })
  output$map <- renderLeaflet({
		get_route_geometry_bw_points(route_input())
  })
}

runApp(shinyApp(ui, server), host="0.0.0.0",port=5050)
