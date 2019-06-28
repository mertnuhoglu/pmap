# name mappings:
# sequence_no = sqn
# salesman_id = smi

init_vars = function() {
	result = list()
	result$salesman = get_salesman()
	result$init_routes_all = get_routes_verbal("report_20190526_00")
	result$init_plan_choices = get_plans()
	result$init_plan_selected = result$init_plan_choices[1]
	result$init_coloring_choices = c("Her rota ayrı renk", "Her gün x satıcı ayrı renk", "Her satıcı ayrı renk")
	result$init_coloring_selected = "Her rota ayrı renk"
	result$init_sqn_selected = 0
	result$init_smi_selected = 7
	result$init_gun_selected = days$gun[1]
	result$init_wkd_selected = gun2week_day(result$init_gun_selected)
	result$init_sqn_choices = get_routes_by_smi_wkd(result$init_routes_all, result$init_smi_selected, result$init_wkd_selected)
	result$init_smi_choices = result$salesman$salesman_id
	result$init_gun_choices = days$gun
	return(result)
}
v = init_vars()

ui <- shinydashboard::dashboardPage(
  shinydashboard::dashboardHeader(title = "Rota Navigatör"
		, shiny::tags$li(class = "dropdown", style = "padding: 8px;",
			shinyauthr::logoutUI("Çıkış")
		)
		, shiny::tags$li(class = "dropdown", 
			shiny::tags$a(shiny::icon("map-marker-alt"), 
			href = "https://i-terative.com",
			title = "i-terative.com")
		)
	)
  , shinydashboard::dashboardSidebar(collapsed = TRUE
		, shiny::uiOutput("sidebar")
	)
  , shinydashboard::dashboardBody(
    shiny::tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}")
    , shinyjs::useShinyjs()
    , shiny::tags$head(shiny::tags$style(".table{margin: 0 auto;}"),
			shiny::tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.contentWindow.min.js", type="text/javascript"), shiny::includeScript("returnClick.js")
    )
		, shinyauthr::loginUI("login")
    , shiny::uiOutput("body")
  )
)

server = function(input, output, session) {
  
  credentials <- callModule(shinyauthr::login, "login", 
                            data = user_base,
                            user_col = user,
                            pwd_col = password_hash,
                            sodium_hashed = TRUE,
                            log_out = shiny::reactive(logout_init()))
  logout_init <- callModule(shinyauthr::logout, "logout", shiny::reactive(credentials()$user_auth))
  user_info <- shiny::reactive({credentials()$info})

  shiny::observe({
    if(credentials()$user_auth) {
			shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
    } else {
      shinyjs::addClass(selector = "body", class = "sidebar-collapse")
    }
  })

	output$sidebar = renderUI({
		req(credentials()$user_auth)
		shiny::fluidRow(
			shiny::column( width = 12
				, shiny::actionButton("reset", "Sıfırla")
				, shiny::selectInput("plan_select", "Rota Planı", choices = v$init_plan_choices, selected = v$init_plan_selected, selectize = F)
				, shiny::checkboxInput("marker_toggle", "Markerları Gizle/Göster", TRUE)
				, shiny::selectInput("coloring_select", "Renk", choices = v$init_coloring_choices, selected = v$init_coloring_selected, selectize = F)
				, shiny::actionButton("sqn_prev", "Önceki")
				, shiny::actionButton("sqn_next", "Sonraki")
				, shiny::selectInput("sqn_select", "Rota sırası", choices = v$init_sqn_choices, selected = v$init_sqn_selected, selectize = F)
				, shiny::actionButton("smi_prev", "Önceki Satıcı")
				, shiny::actionButton("smi_next", "Sonraki Satıcı")
				, shiny::selectInput("smi_select", "Satıcı", choices = v$init_smi_choices, selected = v$init_smi_selected, selectize = T, multiple = T)
				, shiny::actionButton("gun_prev", "Önceki Gün")
				, shiny::actionButton("gun_next", "Sonraki Gün")
				, shiny::selectInput("gun_select", "Gün", choices = v$init_gun_choices, selected = v$init_gun_selected, selectize = T, multiple = T)
			)
		)
	})
	output$body = shiny::renderUI({
		shiny::req(credentials()$user_auth)
    shiny::fluidRow(
      shiny::column( width = 12
				, leaflet::leafletOutput("map")
				, shiny::textOutput("sqn_out")
				, shiny::textOutput("smi_out")
				, shiny::tableOutput("gun_out")
				, shiny::tableOutput("routes")
      )
    )
	})

	state = shiny::reactiveValues(
		routes_all = v$init_routes_all
		, sqn = v$init_sqn_selected
		, routes = get_routes_by_smi_wkd(v$init_routes_all, v$init_smi_selected, v$init_wkd_selected)
		, gun = v$init_gun_selected
		, smi = v$init_smi_selected
	)
	shiny::observeEvent(input$reset, { 
		state$routes_all = v$init_routes_all
		reset_routes(state$routes_all)
	})
	reset_routes = function(routes_all) {
		state$sqn = v$init_sqn_selected
		state$gun = v$init_gun_selected
		state$smi = v$init_smi_selected
		state$routes = get_routes_by_smi_wkd(routes_all, v$init_smi_selected, wkd())
	}
	shiny::observeEvent(input$plan_select, { 
		state$routes_all = get_routes_verbal(input$plan_select) 
		reset_routes(state$routes_all)
	})

	shiny::observe({
		is_show_markers = input$marker_toggle
		coloring_select = input$coloring_select
		if(is.null(is_show_markers) | is.null(coloring_select)) {
			# when app first runs, input$marker_toggle is NULL probably because of the login screen
			return()
		}
		if (is_multiple_route_sets_selected()) {
			state$routeSS = state$routes
		} else {
			state$routeSS = get_route_upto_sequence_no(state$routes, state$sqn)
		}
		map = make_map(state$routeSS, coloring_select)
		if (!is_show_markers) {
			map = remove_markers(map, state$routeSS)
		} 
		state$map = map
	})
	shiny::observeEvent(input$sqn_next, { 
		state$sqn = state$routes[ state$routes$sequence_no == state$sqn, ]$next_sequence_no
	})
	shiny::observeEvent(input$sqn_prev, { 
		state$sqn = state$routes[ state$routes$sequence_no == state$sqn, ]$prev_sequence_no
	})
	shiny::observeEvent(input$sqn_select, { state$sqn = as.numeric(input$sqn_select) })
	shiny::observe({
		updateSelectInput(session, "sqn_select",
			choices = state$routes$sequence_no
			, selected = state$sqn
	)})
	shiny::observeEvent(input$smi_next, {
		state$smi = v$salesman[ v$salesman$salesman_id == state$smi, ]$next_salesman_id
		refresh_salesman_routes()
	})
	shiny::observeEvent(input$smi_prev, {
		state$smi = v$salesman[ v$salesman$salesman_id == state$smi, ]$prev_salesman_id
		refresh_salesman_routes()
	})
	shiny::observeEvent(input$smi_select, {
		state$smi = as.numeric(input$smi_select)
		refresh_salesman_routes()
	})
	shiny::observe({ updateSelectInput(session, "smi_select", selected = state$smi)})
	shiny::observeEvent(input$gun_next, {
		state$gun = days[ days$gun == state$gun, ]$next_gun
		refresh_salesman_routes()
	})
	shiny::observeEvent(input$gun_prev, {
		state$gun = days[ days$gun == state$gun, ]$prev_gun
		refresh_salesman_routes()
	})
	wkd = shiny::reactive({ gun2week_day(state$gun) })
	shiny::observeEvent(input$gun_select, {
		state$gun = input$gun_select
		refresh_salesman_routes()
	})
	shiny::observe({ updateSelectInput(session, "gun_select", selected = state$gun) })
	shiny::observe({ 
		if (is_multiple_route_sets_selected()) {
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
  #routeSS = shiny::reactive({ 
		#if (is_multiple_route_sets_selected()) {
			## if multiple smi/wkd selected, then put all routes
      #return(state$routes)
		#} else {
			#return(get_route_upto_sequence_no(state$routes, state$sqn))
		#}
	#})
	#map = shiny::reactive({ make_map(routeSS()) })
	is_multiple_route_sets_selected = shiny::reactive({ length(state$smi) * length(wkd()) > 1 })
  output$routes = renderTable({ state$routeSS })
  #output$map = renderLeaflet({ map() })
  output$map = renderLeaflet({ state$map })

  output$sqn_out = renderText({ state$sqn })
  output$smi_out = renderText({ state$smi })
  output$gun_out = renderText({ state$gun })

	refresh_salesman_routes = function() {
		state$routes = get_routes_by_smi_wkd(state$routes_all, state$smi, wkd())
		state$sqn = 0
		return(state)
	}
}

run_app = function() {
	shiny::runApp(shiny::shinyApp(ui, server), host="0.0.0.0",port=5050)
}
