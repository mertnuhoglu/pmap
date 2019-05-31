#!/bin/bash

sudo apt-get update &&

sudo echo 'options(repos=structure(c(CRAN="https://mirror.las.iastate.edu/CRAN/")))' >> "/usr/lib/R/etc/Rprofile.site"
sudo apt-get -y install r-base &&
sudo -i R -e 'install.packages(c("dplyr","readr", "shiny", "rmarkdown"))' &&
sudo -i R -e 'install.packages(c("leaflet", "rjson", "bitops", "sp", "glue"))' 
