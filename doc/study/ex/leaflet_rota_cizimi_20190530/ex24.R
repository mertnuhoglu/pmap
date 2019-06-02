library(shiny)

ui = fluidPage(
  title = "Rotalar arasında navigasyon",
  sidebarLayout(
    sidebarPanel(
			actionButton("prev_route", "Önceki")
			, actionButton("next_route", "Sonraki")
		)
		, mainPanel(
			textOutput("seq_no")
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
}

runApp(shinyApp(ui, server), host="0.0.0.0",port=5050)
