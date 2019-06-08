library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)
source("get_routes.R")
source("pvrp.R")
source("login.R")

# name mappings:
# sequence_no = sqn
# salesman_id = smi
# salesman_no = smn

routes_all = get_routes_verbal()
salesman = get_salesman()
init_sqn_selected = 0
init_smn_selected = 1
init_smi_selected = 7
init_gun_selected = days$gun[1]
init_wkd_selected = gun2week_day(init_gun_selected)
init_sqn_choices = get_routes_by_smi_wkd(routes_all, init_smi_selected, init_wkd_selected)
init_smi_choices = salesman$salesman_id
init_gun_choices = days$gun

ui <- dashboardPage(
  dashboardHeader(title = "Rota Navigatör"
		, tags$li(class = "dropdown", style = "padding: 8px;",
			shinyauthr::logoutUI("Çıkış")
		)
		, tags$li(class = "dropdown", 
			tags$a(icon("map-marker-alt"), 
			href = "https://i-terative.com",
			title = "i-terative.com")
		)
	)
  , dashboardSidebar(collapsed = TRUE
		, uiOutput("sidebar")
	)
  , dashboardBody(
    tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}")
    , shinyjs::useShinyjs()
    , tags$head(tags$style(".table{margin: 0 auto;}"),
			tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.contentWindow.min.js", type="text/javascript"), includeScript("returnClick.js")
    )
		, shinyauthr::loginUI("login")
    , uiOutput("body")
  )
)

server = function(input, output, session) {
  
  credentials <- callModule(shinyauthr::login, "login", 
                            data = user_base,
                            user_col = user,
                            pwd_col = password_hash,
                            sodium_hashed = TRUE,
                            log_out = reactive(logout_init()))
  logout_init <- callModule(shinyauthr::logout, "logout", reactive(credentials()$user_auth))
  user_info <- reactive({credentials()$info})

  observe({
    if(credentials()$user_auth) {
			shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
    } else {
      shinyjs::addClass(selector = "body", class = "sidebar-collapse")
    }
  })

	output$sidebar = renderUI({
		req(credentials()$user_auth)
		fluidRow(
			column( width = 12
				, actionButton("reset", "Sıfırla")
				, actionButton("sqn_prev", "Önceki")
				, actionButton("sqn_next", "Sonraki")
				, selectInput("sqn_select", "Rota sırası", choices = init_sqn_choices, selected = init_sqn_selected, selectize = F)
				, actionButton("smn_prev", "Önceki Satıcı")
				, actionButton("smn_next", "Sonraki Satıcı")
				, selectInput("smi_select", "Satıcı", choices = init_smi_choices, selected = init_smi_selected, selectize = T, multiple = T)
				, actionButton("gun_prev", "Önceki Gün")
				, actionButton("gun_next", "Sonraki Gün")
				, selectInput("gun_select", "Gün", choices = init_gun_choices, selected = init_gun_selected, selectize = T, multiple = T)
			)
		)
	})
	output$body = renderUI({
		req(credentials()$user_auth)
    fluidRow(
      column( width = 12
				, leafletOutput("map")
				, textOutput("sqn_out")
				, textOutput("smn_out")
				, tableOutput("gun_out")
				, tableOutput("routes")
      )
    )
	})

	state = reactiveValues(sqn = init_sqn_selected, routes = get_routes_by_smi_wkd(routes_all, init_smi_selected, init_wkd_selected), smn = init_smn_selected, gun = init_gun_selected, smi = init_smi_selected)
	observeEvent(input$reset, { 
		state$sqn = init_sqn_selected
		state$smn = init_smn_selected
		state$gun = init_gun_selected
		state$smi = init_smi_selected
		state$routes = get_routes_by_smi_wkd(routes_all, init_smi_selected, wkd())
	})

	observeEvent(input$sqn_next, { 
		#state$sqn = state$sqn + 1 
		state$sqn = state$routes[ state$routes$sequence_no == state$sqn, ]$next_sequence_no
	})
	observeEvent(input$sqn_prev, { 
		#state$sqn = state$sqn - 1 
		state$sqn = state$routes[ state$routes$sequence_no == state$sqn, ]$prev_sequence_no
	})
	observeEvent(input$sqn_select, { state$sqn = as.numeric(input$sqn_select) })
	observe({
		updateSelectInput(session, "sqn_select",
			choices = state$routes$sequence_no
			, selected = state$sqn
	)})
	observeEvent(input$smn_next, {
		#state$smn = state$smn + 1
		state$smi = salesman[ salesman$salesman_id == state$smi, ]$next_salesman_id
		#refresh_salesman_no()
		refresh_salesman_id()
	})
	observeEvent(input$smn_prev, {
		#state$smn = state$smn - 1
		state$smi = salesman[ salesman$salesman_id == state$smi, ]$prev_salesman_id
		#refresh_salesman_no()
		refresh_salesman_id()
	})
	observeEvent(input$smi_select, {
		state$smi = as.numeric(input$smi_select)
		refresh_salesman_id()
	})
	observe({ updateSelectInput(session, "smi_select", selected = state$smi)})
	observeEvent(input$gun_next, {
		state$gun = days[ days$gun == state$gun, ]$next_gun
		refresh_salesman_routes()
	})
	observeEvent(input$gun_prev, {
		state$gun = days[ days$gun == state$gun, ]$prev_gun
		refresh_salesman_routes()
	})
	wkd = reactive({ gun2week_day(state$gun) })
	observeEvent(input$gun_select, {
		state$gun = input$gun_select
		refresh_salesman_routes()
	})
	observe({ updateSelectInput(session, "gun_select", selected = state$gun) })
	observe({ 
		if (length(state$smi) * length(wkd()) > 1) {
			# we cannot navigate stops in a route group when multiple different route groups are selected
			shinyjs::disable("sqn_prev") 
			shinyjs::disable("sqn_next") 
			shinyjs::disable("sqn_select") 
		} else {
			shinyjs::enable("sqn_prev") 
			shinyjs::enable("sqn_next") 
			shinyjs::enable("sqn_select") 
		}
	})
  routeSS = reactive({ 
		if (length(state$smi) * length(wkd()) > 1) {
			# if multiple smi/wkd selected, then put all routes
      return(state$routes)
		} else {
			return(get_route_upto_sequence_no(state$routes, state$sqn))
		}
	})
  output$routes = renderTable({ routeSS() })
  output$map = renderLeaflet({ make_map(routeSS()) })

  output$sqn_out = renderText({ state$sqn })
  output$smn_out = renderText({ state$smn })
  output$gun_out = renderText({ state$gun })

	refresh_salesman_no = function() {
		state$smi = (dplyr::filter(salesman, salesman_no == state$smn))$salesman_id
		refresh_salesman_routes()
	}
	refresh_salesman_id = function() {
		state$smn = (dplyr::filter(salesman, salesman_id %in% state$smi))$salesman_no
		refresh_salesman_routes()
	}
	refresh_salesman_routes = function() {
		state$routes = get_routes_by_smi_wkd(routes_all, state$smi, wkd())
		state$sqn = 0
		return(state)
	}
}

runApp(shinyApp(ui, server), host="0.0.0.0",port=5050)
