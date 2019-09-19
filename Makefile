build:
	R -e 'devtools::document(); devtools::build_vignettes(); devtools::build(); devtools::install()'

