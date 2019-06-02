# https://stackoverflow.com/questions/21465411/r-shiny-passing-reactive-to-selectinput-choices

library(shiny)

runApp(list(
  ui = bootstrapPage(
    selectInput('dataset', 'Choose Dataset', c('mtcars', 'iris')),
    selectInput('columns', 'Columns', "")
  ),
  server = function(input, output, session){
    outVar = reactive({
      mydata = get(input$dataset)
      names(mydata)
    })
    observe({
      updateSelectInput(session, "columns",
      choices = outVar()
    )})
  }
))

