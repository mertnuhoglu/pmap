library(dplyr)

FMCGVRP_PROJECT_DIR = Sys.getenv("FMCGVRP_PROJECT_DIR")
if (FMCGVRP_PROJECT_DIR == "") {
	FMCGVRP_PROJECT_DIR = "~"
}

get_salesman = function() {
	readr::read_tsv(glue::glue("{FMCGVRP_PROJECT_DIR}/pvrp_data/stlistesi.tsv")) %>%
		dplyr::rename( salesman_id = TerritoryId) %>%
		dplyr::mutate( salesman_no = dplyr::row_number() ) %>%
		dplyr::select( salesman_id, salesman_no )
}


