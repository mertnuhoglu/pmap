library(dplyr)

get_salesman = function() {
	readr::read_tsv("~/gdrive/mynotes/prj/itr/iterative_mert/peyman/stlistesi.tsv") %>%
		dplyr::rename( salesman_id = TerritoryId) %>%
		dplyr::mutate( salesman_no = dplyr::row_number() ) %>%
		dplyr::select( salesman_id, salesman_no )
}


