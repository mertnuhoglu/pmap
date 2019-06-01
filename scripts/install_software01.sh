#!/bin/bash

sudo apt-get update &&

echo 'export OSRM_SERVER=35.204.111.216:5000' >> ~/.bashrc
export OSRM_SERVER=35.204.111.216:5000
sudo echo 'options(repos=structure(c(CRAN="https://mirror.las.iastate.edu/CRAN/")))' >> "/usr/lib/R/etc/Rprofile.site"
sudo apt-get -y install r-base &&
sudo -i R -e 'install.packages(c("dplyr","readr", "shiny", "rmarkdown", "shinydashboard"))' &&
sudo -i R -e 'install.packages(c("leaflet", "rjson", "bitops", "sp", "glue"))' &&

git clone git@bitbucket.org:mertnuhoglu/pmap.git &&
git clone git@bitbucket.org:mertnuhoglu/pvrp.git
mkdir -p ~/pvrp/out

