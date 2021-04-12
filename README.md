
# pmap: route navigator app

## Setup nginx

Ref: `Run nginx <url:/Users/mertnuhoglu/projects/itr/vrp/vrp_doc/dentas/process_setup_dentas.Rmd#tn=Run nginx>`

Edit `nginx.conf` in `~/projects/itr/vrp/vrp/nginx/nginx.conf` for reverse proxy

        location / {
            proxy_pass http://peymandev.i-terative.com:5050;

Run nginx

``` bash
docker exec -it vrp_nginx-router_1 bash
certbot certonly --webroot -w /usr/share/nginx/html -d peymandev.i-terative.com 
docker-compose stop
docker-compose up
``` 

## Download route data:

Rota verileri `pvrp_data` reposu içindeki `out/` dizininde:

``` bash
git clone git@bitbucket.org:mertnuhoglu/pvrp_data.git
``` 

## Setup pmap software

Prerequisite: `~/projects/itr/peyman/pvrp/scripts/install_software_common.sh`

Run `~/projects/itr/peyman/pmap/scripts/install_software01.sh`

``` bash
cd ~/pmap
make build
``` 

# Run pmap app

Run `~/projects/itr/peyman/pmap/R/route_navigator.R`

``` bash
R --vanilla
``` 

opt01: using `devtools`

``` r
devtools::load_all()
run_app()
``` 

opt02: as R package

``` r
pmap::run_app()
``` 

Open in browser: 

		https://peymandev.i-terative.com
		http://localhost:5050

# Tests

## Test scripts to reproduce data

Check `~/projects/itr/peyman/pmap/tests/testthat/test-get_routes.R`

Run test scripts interactively. Source init functions manually.

## Run automated tests

``` r
devtools::test()
``` 


