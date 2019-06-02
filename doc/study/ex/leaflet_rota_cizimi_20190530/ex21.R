library(shiny)

operation = function(routes, seq) {
	seq + 1
}

ui = fluidPage(
  sidebarLayout(
    sidebarPanel(
      selectInput(
        'sequence_no', 'Rota noyu seçin', choices = routes$sequence_no,
      )
		)
		, mainPanel(
      tableOutput("routes")
    )

	)
)

server = function(input, output) {
  input_seq <- reactive({
		input$sequence_no
  })
  output$routes <- renderTable({
		operation(input_seq)
  })
}

runApp(shinyApp(ui, server), host="0.0.0.0",port=5050)
