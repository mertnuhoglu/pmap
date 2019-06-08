library(dplyr)

PEYMAN_PROJECT_DIR = Sys.getenv("PEYMAN_PROJECT_DIR")
if (PEYMAN_PROJECT_DIR == "") {
	PEYMAN_PROJECT_DIR = "~"
}

get_salesman = function() {
	readr::read_tsv(glue::glue("{PEYMAN_PROJECT_DIR}/pvrp_data/stlistesi.tsv")) %>%
		dplyr::rename( salesman_id = TerritoryId) %>%
		dplyr::mutate( salesman_no = dplyr::row_number() ) %>%
		dplyr::select( salesman_id, salesman_no )
}

days = dplyr::tibble(
	week_day = 0:5
	, day = c("monday", "tuesday", "wednesday", "thursday", "friday", "saturday")
	, gun = c("PAZARTESİ", "SALI", "ÇARŞAMBA", "PERŞEMBE", "CUMA", "CUMARTESİ")
	, next_gun = c("SALI", "ÇARŞAMBA", "PERŞEMBE", "CUMA", "CUMARTESİ", "PAZARTESİ")
	, prev_gun = c("CUMARTESİ", "PAZARTESİ", "SALI", "ÇARŞAMBA", "PERŞEMBE", "CUMA")
)

gun2week_day = function(gun) {
	days[ days$gun == gun, ]$week_day
}
