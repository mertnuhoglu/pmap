#!/bin/bash

echo 'export OSRM_SERVER=35.204.111.216:5000' >> ~/.bashrc
export OSRM_SERVER=35.204.111.216:5000
sudo -i R -e 'install.packages(c("shiny", "rmarkdown", "shinydashboard", "usethis", "testthat"))' &&
sudo -i R -e 'install.packages(c("leaflet", "rjson", "bitops", "sp", "sf"))' &&
sudo -i R -e 'install.packages(c("sodium", "curl", "devtools", "shinyjs"))' &&
sudo apt-get -y install libsodium-dev &&
sudo -i R -e 'devtools::install_github("paulc91/shinyauthr")' &&

cd pmap &&
wget https://raw.githubusercontent.com/PaulC91/shinyauthr/master/inst/shiny-examples/shinyauthr_example/returnClick.js -O doc/study/ex/leaflet_rota_cizimi_20190530/returnClick.js &&
cd .. &&
mkdir -p ~/pvrp/out 
