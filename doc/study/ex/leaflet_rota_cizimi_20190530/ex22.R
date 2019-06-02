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
  output$routes <- renderTable({
		get_route_for_sequence_no(routes, as.numeric(input$sequence_no))
  })
  output$map <- renderLeaflet({
		t0 = get_route_for_sequence_no(routes, 2)
		get_route_geometry(t0, 1)
  })
}

runApp(shinyApp(ui, server), host="0.0.0.0",port=5050)
