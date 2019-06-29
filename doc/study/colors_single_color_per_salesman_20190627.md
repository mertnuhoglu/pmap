
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

Check `~/projects/itr/peyman/pmap/tests/testthat/test-get_routes.R`

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

``` r
usethis::use_test("get_routes")
  ##> ~/projects/itr/peyman/pmap/tests/testthat/test-get_routes.R
devtools::test()
``` 

####### Error: otomatik shiny başlıyor

####### Error: could not find function "get_routes_verbal"

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

reactive -> shiny::reactive

#### renklendirme mantığı çok karmaşık, onu basitleştirelim

##### opt01: data_frame ile renkleri tut

``` r
	state = init_state()
	state$routes = get_routes_by_smi_wkd(v$init_routes_all, c(7,12), v$init_wkd_selected)
	state$routeSS = state$routes
	routes = state$routeSS
	is_multiple_color_route = T

	# make_map implementation
	route_groups = routes %>%
		dplyr::group_by(salesman_id, week_day) %>%
		dplyr::group_split()
	orig = routes[1, ] %>%
		dplyr::select(lng = from_lng, lat = from_lat)
	m <- leaflet(width="100%") %>% 
		addTiles() %>%
		addAwesomeMarkers(lng=orig$lng, lat=orig$lat)

	pal = c("red", "purple", "darkblue", "orange", "cadetblue", "green", "darkred", "pink", "gray", "darkgreen", "black")
	gr = 1
	route_group = route_groups[[gr]]
	nrow(route_group) # 18
	if (is_multiple_color_route) {
		t = 1 + (nrow(route_group) / length(pal)) # 2.64
		col = rep(pal, times = t)
		length(pal) # 11
		length(col) # 22
	} else {
		col = rep(pal[gr], times = nrow(route_group))
	}

	# make_map_with_markers implementation
	routes = route_group

	for (sqn in seq_len(nrow(routes))) { # 18
		orig = routes[sqn, ] %>%
			dplyr::select(lng = from_lng, lat = from_lat, customer_name)
		dest = routes[sqn, ] %>%
			dplyr::select(lng = to_lng, lat = to_lat, customer_name, to_point_id)
		rt = route(orig, dest)
		ph = path(rt)
		col[sqn] # length(col) = 22
		icon_num = leaflet::makeAwesomeIcon(text = sqn, markerColor = col[sqn])
	}
``` 

Eğer tek renkli olursa, o zaman `is_multiple_color_route = F` olacak. Bu durumda, `col` hep aynı renkleri içerecek:

``` r
pal[gr] # red
col = rep(pal[gr], times = nrow(route_group))
``` 

Yani `red` olacak tüm `col` vektörü.

Bu durumda `col` vektörünü bir şekilde bir `df` içine koyalım öncelikle.

Muhtemelen `route_group` içine koymalıyız `col` vektörünü.

``` r
route_group
  ##>    salesman_id week_day from_point_id to_point_id ...
  ##>          <dbl>    <dbl>         <dbl>       <dbl> 
  ##>  1           7        0             1         183 
  ##>  2           7        0           183         595 
``` 

Ancak `col` uzunluğu `route_group` uzunluğundan farklı. Onun fazla kısmını kırpmalıyım.

``` r
		col = col[1:nrow(route_group)]
		route_group$color = col
``` 

Test et:

``` r
devtools::load_all()
run_app()
``` 

##### her bir grup için farklı bir renk olsun

tek renk, çok renk vs. renk grupları olsun

``` r
		col_per_route = rep(pal, times = 1 + (nrow(route_group) / length(pal)))
		col_per_route = col_per_route[1:nrow(route_group)]
		col_per_smi_wkd = rep(pal[gr], times = nrow(route_group))
		col_per_smi = rep(pal[gr], times = nrow(route_group))
		route_group$col_per_route = col_per_route
		route_group$col_per_smi_wkd = col_per_smi_wkd
		route_group$col_per_smi = col_per_smi
``` 

###### bu durumda peki renk değiştirmeyi nasıl yapacağız?

Renk parametresi hangi değerlere sahip olabilir:

- Her rota için ayrı renk
- Her gün x satıcı için ayrı renk
- Her satıcı için ayrı renk

Dolayısıyla bu bir dropdown olmalı.

``` r
				, shiny::selectInput("coloring_select", "Renk", choices = v$init_coloring_choices, selected = v$init_coloring_selected, selectize = F)
``` 

###### her satıcı ayrı renk olsun

opt01: route_groups group_by 

`dplyr::group_by(salesman_id)` yaparsak, zaten `route_groups` satıcı bazında oluşturulur.

``` r
	route_groups = routes %>%
		dplyr::group_by(salesman_id) %>%
		dplyr::group_split()
``` 

opt05: for loop kullanmadan renklendirmeyi yap

mutate by group var mı?

`group_indices` var

####### group_indices kullanarak mevcut işlevselliği sağla

``` r
mtcars %>% mutate(g = group_indices(., cyl))
routes %>% mutate(g = group_indices(., salesman_id))
x = group_indices(routes, salesman_id)
routes %>% mutate(g = x)
``` 

Şimdilik bunlar çalışmıyor.

``` r
routes$col_per_route = 1:nrow(routes)
routes$col_per_smi_wkd = group_indices(routes, salesman_id, week_day)
routes$col_per_smi = group_indices(routes, salesman_id)
``` 

######## Bu grup idlerini kullanarak renk ataması yap

opt01: sınırlı bir renk kümesinden başlayarak yap

opt02: sınırsız renk kümesi kullan

######### opt01: sınırlı bir renk kümesinden başlayarak yap

Ref: [master b8be5bd] her satıcıya ayrı renk

opt01: bir join işlemiyle renk tanımla

Renk tablosu oluştur

``` r
colors = tibble::tibble(color = rep(pal, times = 1000)) %>%
	dplyr::mutate(color_id = dplyr::row_number())
``` 

join işlemini nasıl yapacağız?

Rstudio ile incele

Ancak environment variablelar zshenv dosyasından okunmuyor. Rprofile içinde bunları tanımla.

``` r
init_state = function() {
	v = init_vars()

	state = list(
		routes_all = v$init_routes_all
		, sqn = v$init_sqn_selected
		, routes = get_routes_by_smi_wkd(v$init_routes_all, v$init_smi_selected, v$init_wkd_selected)
		, gun = v$init_gun_selected
		, smi = v$init_smi_selected
	)
	#state$routeSS = get_route_upto_sequence_no(state$routes, state$sqn)
	#state$map = make_map(state$routeSS)
	return(state)
}

	state = init_state()
	state$routes = get_routes_by_smi_wkd(v$init_routes_all, c(7,12), v$init_wkd_selected)
	state$routeSS = state$routes
	routes = state$routeSS

	# make_map2
	routes$col_per_route = 1:nrow(routes)
	routes$col_per_smi_wkd = group_indices(routes, salesman_id, week_day)
	routes$col_per_smi = group_indices(routes, salesman_id)
	r0 = routes %>%
		left_join(colors, by = c("col_per_route" = "color_id"))
``` 


