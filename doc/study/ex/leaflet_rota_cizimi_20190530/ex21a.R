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
}

runApp(shinyApp(ui, server), host="0.0.0.0",port=5050)
