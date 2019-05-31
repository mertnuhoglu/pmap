library(shiny)
library(shinydashboard)
library(leaflet)
source("get_routes.R")

ui <- dashboardPage(
  dashboardHeader(),
  dashboardSidebar(),
  dashboardBody(
    tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
    leafletOutput("map")
  )
)

server <- function(input, output) {
  output$map <- renderLeaflet({
		get_routes()
    #leaflet() %>% addTiles() %>% setView(42, 16, 4)
  })
}

runApp(shinyApp(ui, server), launch.browser = TRUE)

