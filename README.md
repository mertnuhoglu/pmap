
# pmap: route navigator app

## Install

Prerequisite: `~/projects/itr/peyman/pvrp/scripts/install_software_common.sh`

Run `~/projects/itr/peyman/pmap/scripts/install_software01.sh`

``` bash
scp ~/projects/itr/peyman/pvrp/out/trips_with_costs.tsv itr01:~/pvrp/out
``` 

#### Run pmap app

``` bash
cd ~/pmap
R --vanilla
``` 

Run `~/projects/itr/peyman/pmap/R/route_navigator.R`

``` r
devtools::load_all()
run_app()
``` 

Open in browser: 

		https://peymandev.i-terative.com
		http://localhost:5050

## Test scripts to reproduce data

Check `~/projects/itr/peyman/pmap/tests/testthat/test-get_routes.R`

Run test scripts interactively. Source init functions manually.

## Run automated tests

``` r
devtools::test()
``` 

