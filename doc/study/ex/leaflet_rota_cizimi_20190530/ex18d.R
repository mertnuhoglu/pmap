library(shiny)
library(leaflet)
source("get_routes.R")

routes = get_routes_verbal()

get_route_for_sequence_no = function(routes, seq) {
	seq + 1
	#sq = c(seq, seq + 1)
	#routes %>%
		#dplyr::filter(sequence_no %in% sq) %>%
		#dplyr::filter(sequence_no == 2) %>%
		#as.data.frame()
	routes %>% 
		dplyr::filter(sequence_no == 2)
}

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
		get_route_for_sequence_no(routes, as.numeric(input$sequence_no))
  })
}

runApp(shinyApp(ui, server), host="0.0.0.0",port=5050)
