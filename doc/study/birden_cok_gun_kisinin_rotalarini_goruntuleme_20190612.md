
## other

### birden çok kişi/gün seçimini state içinde tutalım 

Ref: 

		[master ff52813] birden çok kişi/gün seçimini reaktif olarak state olarak tutalım

#### Error: from_lat not found

		6: twc %>% dplyr::select(salesman_id, week_day, from_point_id, to_point_id,
					 from_lat, from_lng, to_lat, to_lng, sequence_no, customer_name) %>%
				... at get_routes.R#60
		5: get_routes_verbal() at route_navigator.R#13

``` r
	twc = readr::read_tsv(glue::glue("{PEYMAN_PROJECT_DIR}/pvrp/out/trips_with_costs.tsv")) 
``` 

twc'de from_lat ve from_to niye yok?

Belki düzgün oluşturulmadı dosya. Tekrar oluştur. Ref: `Excel dosyasını üret <url:/Users/mertnuhoglu/projects/itr/peyman/pvrp/doc/study/log_20190609.md#tn=Excel dosyasını üret>`

Cause: 

		r9 = r4 %>%
			...
		return(r4)

r9 yerine r4'ü döndürüyormuşum

# birden çok gün ve kişiye ait rotaları görüntüleme

## opt: nasıl implemente edelim

opt01: make_map_with_markers() içinde bir ifthenelse çatallanması yapalım

eğer birden çok kişiye aitse addMarkers kullanmayalım

opt02: yukarıda bir buton olsun: markerları göster/gizle

## opt02: yukarıda bir buton olsun: markerları göster/gizle

Markerları kaldırmak için: `removeMarker()` kullan. Örnek: `~/projects/study/r/shiny/ex/study_shiny/ex01/06.R`

``` r
leaflet() %>% addTiles() %>%
  addMarkers( layerId = "1", lng = -118.456554, lat = 34.078039, label = "orange") %>%
  addMarkers( layerId = "2", lng = -118.556554, lat = 34.078039, label = "red" ) %>%
	removeMarker( layerId = "2" )
``` 

layerId olarak ne kullanalım?

Doğrudan o satış noktasının point_id değeri olabilir.

Ref: `~/projects/itr/peyman/pmap/scripts/test_route_navigator.R`

``` r
addAwesomeMarkers( layerId = dest$to_point_id, ...
``` 

Şimdi bunu remove edecek bir actionButton koymalıyız

``` r
	observeEvent(input$marker_toggle, {

	})
``` 

Bu fonksiyon içinde leaflet map objesini güncellemeliyim. 

Ancak map objesini henüz state içinde tutmuyorum. Doğrudan render ediyorum:

		output$map = renderLeaflet({ make_map(routeSS()) })

Dolayısıyla önce map objesini state içinde tutmalıyım.

Soru: Acaba map objesini state içinde mi tutmalıyım, yoksa bir reactive stream haline mi getirmeliyim?

opt01: state$map şeklinde tut

opt02: map = reactive({make_map()}) şeklinde reactive stream yap

### opt01: state$map şeklinde tut

Bu state objesini nerede güncelleyeceğim peki?

#### Error

		Warning: Error in UseMethod: no applicable method for 'group_by_' applied to an object of class "list"
			49: make_map [get_routes.R#11]
			48: <observer> [route_navigator.R#122]

Hatanın olmasına neden olan kod değişikliği:

``` r
	observe({
		is_show_markers = input$marker_toggle
		state$routeSS = ifelse(
			is_multiple_route_sets_selected()
			, state$routes
			, get_route_upto_sequence_no(state$routes, state$sqn)
		)
		print(glue("is_multiple_route_sets_selected(): {is_multiple_route_sets_selected()}"))
		print(glue("state$routes: {state$routes}"))
		print(glue("get_route_upto_sequence_no(state$routes, state$sqn): {str(get_route_upto_sequence_no(state$routes, state$sqn))}"))
		print(glue("state$routeSS: {str(state$routeSS)}"))
		state$map = make_map(state$routeSS)
	})
``` 

``` r
state$map = make_map(state$routeSS)
``` 

Burada routeSS list türünden bir obje diye şikayet ediyor. Fakat aslında get_route_upto_sequence_no()'ya eşit olmalı ki o da bir df, list değil.

Tam olarak ne dönüyor bunu anlamalıyım.

opt01: ifelse() yerine düz if-else statement kullan

Bu sorunu çözdü. 

Çözüm:

``` r
		if (is_multiple_route_sets_selected()) {
			state$routeSS = state$routes
		} else {
			state$routeSS = get_route_upto_sequence_no(state$routes, state$sqn)
		}
``` 

Muhtemelen, ifelse() girdisinin veri yapısıyla ilgili bir sorun var. type safety meselesi. 

### opt02: map = reactive({make_map()}) şeklinde reactive stream yap

``` r
map = reactive({ make_map(routeSS()) })
``` 

### şimdi markerları kaldıralım 

Ref: [master b24ea2a] toggle markers visibility button: show/hide them

#### Error

		Adding missing grouping variables: `salesman_id`, `week_day`
		Warning: Error in !: invalid argument type
			48: <observer> [route_navigator.R#119]
			 5: runApp

daha toggle objesi oluşturulmadığından hata veriyor olmalı

``` r
is_show_markers = input$marker_toggle
``` 

Bu şu an NULL

#### Error

		Warning: Error in eval: argument "routes" is missing, with no default
			52: eval
			51: eval
			50: %>%
			49: remove_markers [get_routes.R#11]
			48: <observer> [route_navigator.R#128]

#### Error: Çok uzun zaman alıyor, for loop

``` r
remove_markers = function(map, routes) {
	route_groups = routes %>%
		dplyr::group_by(salesman_id, week_day) %>%
		dplyr::group_split()

	for (gr in seq_along(route_groups)) {
		route_group = route_groups[[gr]]
		for (sqn in seq_len(nrow(routes))) {
			dest = routes[sqn, ] %>%
				dplyr::select(lng = to_lng, lat = to_lat, customer_name, to_point_id)
			map = map %>%
				removeMarker( layerId = as.character(dest$to_point_id) )
		}
	}
	return(map)

}
``` 

opt01: Acaba routes yanlış veriyi içeriyor olabilri mi?

opt02: Elle test et

routeSS var mı?

``` r
state$map = remove_markers(state$map, state$routeSS)
``` 

opt03: print et verileri

Sürekli aynı noktayı basıyor. Sanki tekrar tekrar çağrılıyor gibi. reactive() ile alakalı olabilir.

``` r
			state$map = remove_markers(state$map, state$routeSS)
``` 

`map` değişince, bu `observe()` tekrar kendini çağırıyor galiba.

##### map recursive bir şekilde değişmesin

opt:

		opt01: map2 olabilir mi?

		opt02: make_map içinde bunu hallet, addMarker çağrılmasın hiç

opt01: map2 olabilir mi?

Çözüm:

state$map hem LHS, hem RHS içinde kullanılmasın. 

``` r
		map = make_map(state$routeSS)
		if (!is_show_markers) {
			map = remove_markers(map, state$routeSS)
		} 
		state$map = map
``` 

#### Error: markerlar silinmiyor

opt

		opt01: layerId yanlış
		opt02: addAwesomeMarkers ile çalışmıyor olabilir
		opt03: ilk eklerken de as.character kullan

opt02: addAwesomeMarkers ile çalışmıyor olabilir

Çalışıyor. Testi: `~/projects/study/r/shiny/ex/study_shiny/ex01/07.R`

opt03: ilk eklerken de as.character kullan

``` r
addAwesomeMarkers( layerId = as.character(dest$to_point_id), lng=dest$lng, lat=dest$lat, icon = icon_num, popup=dest$customer_name, label = glue("{sqn} - {dest$customer_name}")) 
``` 

Çalıştı. Sorun buymuş

## tüm triplerin rengi aynı olsun

Ref: [master 41b923c] all the trips in one route group can become single color

opt:

		opt01: yine bir toggle butonu olsun

### opt01: yine bir toggle butonu olsun renkleri sabit veya değişken yapacak

Şurada rengi ekliyoruz triplere:

``` r
addPolylines(data = ph, label = route_label(rt), color = col[sqn], opacity=1, weight = 3) %>%
``` 

Nasıl yapabiliriz?

		opt01: Dynamic Legend'da kullanılan yöntem: leafletProxy() kullan
		opt02: Sıfırdan haritayı tekrar oluştur

#### opt01: Dynamic Legend'da kullanılan yöntem: leafletProxy() kullan

https://github.com/cenuno/shiny/tree/master/Interactive_UI/Dynamic_Legend

##### basit bir örnek yapalım leafletProxy() kullanarak

Ref: `use leafletProxy() instead of leaflet() <url:/Users/mertnuhoglu/projects/study/r/shiny/study_leaflet.Rmd#tn=use leafletProxy() instead of leaflet()>`

##### leaflet() doğrudan kullanmak yerine leafletProxy() kullanalım

Bunu nasıl yapacağımı bulamadım. Sonra bakarız buna.

###### bizdeki map ve state$map modelini basit örnekte uygulayalım önce

Ref: `03: use state$map and a local map <url:/Users/mertnuhoglu/projects/study/r/shiny/study_leaflet.Rmd#tn=03: use state$map and a local map>`

---

#### başka ne yöntemler var?

``` r
addPolylines(data = ph, label = route_label(rt), color = col[sqn], opacity=1, weight = 3) %>%
``` 

#### opt02: Sıfırdan haritayı tekrar oluştur

Bu durumda `make_map_with_markers` fonksiyonuna arg olarak renk gösterme seçeneğini göndermeliyiz.

		opt01: is_single_color argümanı gönder
		opt02: renk paletini argüman olarak gönder
		opt03: routes içine bir kolon olarak renkleri ekle
		opt04: her zaman tek renk kullan, fazladan renk hiç kullanma zaten
		opt05: renkleri routes tablosunda iki farklı kolonda tut

opt02: renk paletini argüman olarak gönder

Ancak mevcut durumda renkleri col[sqn] ile alıyorum. Dolayısıyla renk paleti routes ile aynı büyüklükte olmak zorunda.

opt05: renkleri routes tablosunda iki farklı kolonda tut

Bu durumda `dest$marker_color` ve `dest$route_set_color` kullanmak yeterli olur

Ancak bu defa da bu renklerin en baştan herkes için farklılığı temin edilebilir mi?

##### opt01: is_single_color argümanı gönder

Çok renkliyse, col şimdiki gibi olmalı. Değilse nasıl olmalı?

		opt01: sqn'e bağlı olmasın
		opt02: sqn'e bağlı olsun

`make_map_with_markers` sadece bir rota kümesini içerdiğinden diğerlerinin ne olduğunu bilemiyoruz. Bu durumda, renk paletini dışarıdan vermemiz gerekiyor.

``` r
make_map = function(routes, is_multiple_color_route = T) {
...
	pal = c("red", "purple", "darkblue", "orange", "cadetblue", "green", "darkred", "pink", "gray", "darkgreen", "black")
	for (gr in seq_along(route_groups)) {
		route_group = route_groups[[gr]]
		if (is_multiple_color_route) {
			col = rep(pal, times = 1 + (nrow(route_group) / length(pal)))
		} else {
			col = rep(pal[gr], times = nrow(route_group))
		}
		m = make_map_with_markers(m, route_group, col)
``` 

`is_multiple_color_route` kullanıcı girişinden gelmeli.

### deploy et

Ref: 

		pmap: [master c688345] put trips_with_costs.tsv into pvrp_data
		pvrp: [master 14821a0] put trips_with_costs.tsv into pvrp_data

Error: Error in .f(.x[[i]], ...) : object 'customer_name' not found

Elle çalıştır

``` r
routes_all = get_routes_verbal()
``` 

Sebebi: `trips_with_costs.tsv` bunun güncellenmesi lazım.

Bu dosyayı da pvrp_data içine alalım.

Önce trips_with_costs.tsv dosyasını 00 routes.csv dosyasından tekrar oluşturalım.

`~/projects/itr/peyman/pvrp/out/trips_with_costs.tsv`
`/Users/mertnuhoglu/projects/itr/peyman/pvrp_data/out/report_20190526_00/trips_with_costs.tsv`

