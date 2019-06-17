#!/bin/bash

sudo apt-get update &&

echo 'export OSRM_SERVER=35.204.111.216:5000' >> ~/.bashrc
export OSRM_SERVER=35.204.111.216:5000
sudo echo 'options(repos=structure(c(CRAN="https://mirror.las.iastate.edu/CRAN/")))' >> "/usr/lib/R/etc/Rprofile.site"
sudo apt-get -y install r-base &&
sudo apt-get -y install libcurl4-openssl-dev libssl-dev &&
sudo -i R -e 'install.packages(c("dplyr","readr", "shiny", "rmarkdown", "shinydashboard"))' &&
sudo -i R -e 'install.packages(c("leaflet", "rjson", "bitops", "sp", "glue"))' &&
sudo -i R -e 'install.packages(c("sodium", "curl", "devtools", "shinyjs"))' &&
sudo -i R -e 'devtools::install_github("paulc91/shinyauthr")' &&


git clone git@bitbucket.org:mertnuhoglu/pmap.git &&
cd pmap &&
wget https://raw.githubusercontent.com/PaulC91/shinyauthr/master/inst/shiny-examples/shinyauthr_example/returnClick.js -O doc/study/ex/leaflet_rota_cizimi_20190530/returnClick.js &&
cd .. &&
git clone git@bitbucket.org:mertnuhoglu/pvrp.git &&
mkdir -p ~/pvrp/out &&
echo '
export OSRM_SERVER=35.204.111.216:5000
export PEYMAN_PROJECT_DIR="$HOME"
' >> ~/.bashrc &&
source ~/.bashrc 

