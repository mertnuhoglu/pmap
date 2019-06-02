library(shiny)

ui = fluidPage(
  sidebarLayout(
    sidebarPanel(
      selectInput(
        'numara', 'Numara', choices = c(0,1,2),
      )
		)
		, mainPanel(
      textOutput("out")
    )
	)
)

server = function(input, output) {
	output$out = renderText({
		print(class(input$numara))
		##> character
		#input$numara + 1
	})
}

runApp(shinyApp(ui, server), host="0.0.0.0",port=5050)
