library(dplyr)

FMCGVRP_PROJECT_DIR = Sys.getenv("FMCGVRP_PROJECT_DIR")
if (FMCGVRP_PROJECT_DIR == "") {
	FMCGVRP_PROJECT_DIR = "~"
}

get_salesman = function() {
	readr::read_tsv(glue::glue("{FMCGVRP_PROJECT_DIR}/pvrp_data/stlistesi.tsv")) %>%
		dplyr::rename( salesman_id = TerritoryId) %>%
		dplyr::mutate( salesman_no = dplyr::row_number() ) %>%
		dplyr::select( salesman_id, salesman_no ) %>%
		dplyr::mutate(
			prev_salesman_id = dplyr::lag(salesman_id, default = dplyr::last(salesman_id))
			, next_salesman_id = dplyr::lead(salesman_id, default = dplyr::first(salesman_id))
		) 
}

days = dplyr::tibble(
	week_day = 0:5
	, day = c("monday", "tuesday", "wednesday", "thursday", "friday", "saturday")
	, gun = c("PAZARTESİ", "SALI", "ÇARŞAMBA", "PERŞEMBE", "CUMA", "CUMARTESİ")
	, next_gun = c("SALI", "ÇARŞAMBA", "PERŞEMBE", "CUMA", "CUMARTESİ", "PAZARTESİ")
	, prev_gun = c("CUMARTESİ", "PAZARTESİ", "SALI", "ÇARŞAMBA", "PERŞEMBE", "CUMA")
)

color_palette = c("red", "purple", "darkblue", "orange", "cadetblue", "green", "darkred", "pink", "gray", "darkgreen", "black")
colors = dplyr::tibble(color = rep(color_palette, times = 1000)) %>%
	dplyr::mutate(color_id = dplyr::row_number())

gun2week_day = function(gun) {
	days[ days$gun == gun, ]$week_day
}

get_plans = function() {
  list.files(path = glue::glue("{FMCGVRP_PROJECT_DIR}/pvrp_data/out"), include.dirs = T, pattern = "^report_\\d+.*")
}
