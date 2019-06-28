
## Birden çok satıcıda aynı satıcının rotaları tek renk olsun

### Logs 20190627 

``` r
		if (is_multiple_color_route) {
			col = rep(pal, times = 1 + (nrow(route_group) / length(pal)))
		} else {
			col = rep(pal[gr], times = nrow(route_group))
		}
``` 

`route_group` nedir?

``` r
	for (gr in seq_along(route_groups)) {
		route_group = route_groups[[gr]]
``` 

``` r
	route_groups = routes %>%
		dplyr::group_by(salesman_id, week_day) %>%
		dplyr::group_split()
``` 

#### reproduce ederek route_group nedir bul

##### unit testler hazırla reproduce etmek için

###### package oluştur unit testleri oluşturmak için

``` r
library(usethis)
create_package("pmap")
``` 

``` r
usethis::use_testthat()
usethis::use_test("test01")
devtools::test()
``` 

###### get_routes() fonksiyonunu test scriptinden çağır

Edit `~/projects/itr/peyman/pmap/tests/testthat/test-test01.R`

``` r
test_that("get_routes works", {
	routes_all = get_routes_verbal()
``` 

####### Error:

		test-test01.R:11: error: get_routes works
		could not find function "get_routes_verbal"

``` r
library(usethis)
devtools::test()
``` 

opt01: source() ifadelerini sil R dosyalarından

Yine aynı hatayı veriyor

######## opt02: çalışan bir örneğe kendi fonksiyonlarını eklemeyi dene

``` bash
mkdir -p doc/study/ex/colors_single_color_per_salesman_20190627
cd $_
R
``` 

``` r
library(usethis)

create_package("ex01")
``` 

``` r
usethis::use_testthat()
usethis::use_test("test01")
  ##> ~/projects/itr/peyman/pmap/doc/study/ex/colors_single_color_per_salesman_20190627/ex01/tests/testthat/test-test01.R
``` 

``` r
test_that("ex01_fun works", {
	ex01_fun()
  expect_equal(2 * 2, 4)
})
``` 

``` r
devtools::test()
``` 

All tests pass

Now, add `get_routes_verbal` too

``` r
test_that("get_routes_verbal works", {
	init_routes_all = get_routes_verbal("report_20190526_00")
  expect_equal(2 * 2, 4)
})
``` 

All tests pass.

######## opt03: tüm fonksiyonları devtools ile yüklemeyi dene

``` r
devtools::load_all()
``` 

Ancak hiçbir global fonksiyon veya değişkene erişemiyorum.

Sebep: Tüm dosyalar scripts/ klasörü içinde. R/ klasörüne taşımamıştım ki.

####### Error: reactive not found


