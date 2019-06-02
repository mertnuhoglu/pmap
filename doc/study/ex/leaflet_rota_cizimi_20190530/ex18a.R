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
    )
	)
)

server = function(input, output) {
  input_seq <- reactive({
		as.numeric(input$sequence_no)
  })
  output$routes <- renderTable({
		get_route_for_sequence_no(routes, input_seq)
  })
}

runApp(shinyApp(ui, server), host="0.0.0.0",port=5050)
