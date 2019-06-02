library(shiny)
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
  output$routes <- renderTable({
    routes %>%
			dplyr::filter(sequence_no == input$sequence_no)
  })
}

runApp(shinyApp(ui, server), host="0.0.0.0",port=5050)
