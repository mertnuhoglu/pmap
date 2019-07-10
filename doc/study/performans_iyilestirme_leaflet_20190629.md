
# Performans İyileştirme Leaflet 20190629 

## Logs

Sorun her make_map çağrıldığında tüm noktalar arasındaki rotalar tekrar hesaplanıyor:

``` r
		rt = route(orig, dest)
``` 

``` r
route = function(orig, dest) {
	url = glue::glue("http://{osrm_server}/route/v1/driving/{orig$lng},{orig$lat};{dest$lng},{dest$lat}?overview=full")
	return(rjson::fromJSON(file=url))
}
``` 

### tüm rotaları batch olarak en başta çek

driving servisinin kullanıldığı önceki kodlar:

Code: `~/projects/itr/peyman/pvrp/doc/study/ex/peyman_osrm_kurulumu_20190521/ex18.sh`

``` bash
curl "http://$HOST/route/v1/driving/29.208498,40.890795;29.246330,40.989400?steps=true" | jq . > ex06.json
``` 

``` bash
HOST=35.204.111.216:5000
  #FILE=coordinates50.csv
FILE=$1
COORDINATES=$(cat ${FILE} | tr '\n' ';' | sed -e 's/;$//')
SERVICE=table
curl "http://${HOST}/${SERVICE}/v1/driving/${COORDINATES}?annotations=distance,duration" | jq . > ex18.json
``` 

Output: `~/projects/itr/peyman/pvrp/doc/study/ex/peyman_osrm_kurulumu_20190521/ex06.json`

``` json
{
  "code": "Ok",
  "routes": [
    {
      "geometry": "_oqxF{xgqDkC|G_v@tBcl@ed@yRoFcv@jCuZrQy_@ehAqf@bNyKaDsMpPwgBrRsaAkKoQiV_UpDcZaKcN~@gp@etAoCyX~D{MiFsa@",
``` 

#### ex18.sh iki nokta arası rotaları mı çekiyor yoksa tüm od_table dosyasını mı?

``` bash
bash ex18.sh coordinates100.csv
``` 

od_table dosyasını çekiyor, çünkü table servisini kullanıyor

#### ex11.sh birden çok noktanın rotasını çekince ne oluyor?

`~/projects/itr/peyman/pvrp/doc/study/ex/peyman_osrm_kurulumu_20190521/ex11.sh`

``` bash
COORDINATES='29.208498,40.890795;29.24633,40.9894;29.08812,40.99462'
curl "http://${DEMO}/route/v1/driving/${COORDINATES}" | jq . > ex11.json
``` 

Bu durumda 3 noktadan geçen rotayı tek bir geometry objesi olarak dönüyor:

`~/projects/itr/peyman/pvrp/doc/study/ex/peyman_osrm_kurulumu_20190521/ex11.json`

#### url'leri oluşturalım

ikişerli kombinasyonlar halinde tüm rota sıralamasındaki noktaların arasındaki koordinatları oluşturalım

Örnek:

``` bash
29.208498,40.890795
29.24633,40.9894
29.08812,40.99462
``` 

->

``` bash
29.208498,40.890795;29.24633,40.9894
29.24633,40.9894;29.08812,40.99462
``` 

Buna pairs of coordinates diyelim.

##### pairs of coordinates oluştur

Bir join operasyonuyla yapalım bunu.

Mevcut tabloyu önce bir dataframe'e çevirelim

Edit `/Users/mertnuhoglu/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/ex01.R`

Her birine bir id ver

point_id zaten points tablosunda olmalı

``` r
read_points = function() {
	pt = readr::read_tsv(glue::glue("{PEYMAN_PROJECT_DIR}/pvrp_data/normal/points.tsv"))
}
``` 

Bu durumda önce rotaların hangi noktalardan oluştuğuna ihtiyacım var. 

Bu bilgi de trips_with_costs.tsv dosyasında var.

Check `~/projects/itr/peyman/pvrp/out/trips_with_costs.tsv`

Verileri buradan okuyalım

``` r
c0 = readr::read_tsv("trips_with_costs.tsv") %>%
	dplyr::select(from_point_id, to_point_id, from_lng, from_lat, to_lng, to_lat)
``` 

Şimdi url'leri oluşturalım

``` r
c1 = c0 %>%
	dplyr::mutate(route_url = glue::glue("http://{osrm_server}/route/v1/driving/{from_lng},{from_lat};{to_lng},{to_lat}?overview=full"))
``` 

Bir url test edelim

``` r
c1$route_url[1]
  ##> http://35.204.111.216:5000/route/v1/driving/29.208498,40.890795;29.27214,40.96378?overview=full
``` 

``` bash
curl http://35.204.111.216:5000/route/v1/driving/29.208498,40.890795;29.27214,40.96378?overview=full | jq . > t01.json
``` 

Result: `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/t01.json`

#### bash veya R içinden curl ile tüm urlleri çekip kaydet

##### opt01: geometry verilerini kaydet doğrudan tabloya

opt01: curl çağrısı yap

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/ex02.R`

``` r
curl_download(c1$route_url[1], "t02.json")
``` 

opt02: fromJSON kullan

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/ex03.R`

``` r
c3 = c2 %>%
	dplyr::mutate(route_geometry = (rjson::fromJSON(file = route_url))$routes[[1]]$geometry)
``` 

###### Error: route_url kullanamıyorum

		Error in file(con, "r") : invalid 'description' argument

başka fonksiyonların kullanımında da mı böyle oluyor?

Edit `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/ex04.R`

##### opt02: json dosyalarını kaydet

###### opt01: curl komutlarını hazırla > filename.json çıktılarıyla birlikte

Edit `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/ex05.R`

``` r
c3 = c2 %>%
	dplyr::mutate(curl_cmd = glue::glue("curl {route_url} > {from_point_id}_{to_point_id}.json"))
``` 

curl komutlarını çıktıla: `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/curl_cmd.sh`

``` r
writeLines(c3$curl_cmd, "curl_cmd.sh")
system("bash curl_cmd.sh", intern=T)
``` 

#### json dosyalarını parse et

json dosyalarını okuyup bir tabloda birleştir çıktıları

Edit `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/ex06.R`

``` r
for (f in c3$file_name) {
  j0 = rjson::fromJSON(file=f)
	j1 = j0$routes[[1]]$geometry
	j2 = decode(j1, multiplier=1e5)
}
``` 

#### geometry verilerini dfye ekle

Edit `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/ex07.R`

``` r
geometry = lapply(c3$file_name, function(f) {
  j0 = rjson::fromJSON(file=f)
	j1 = j0$routes[[1]]$geometry
}) %>% unlist()

c4 = c3 %>%
	dplyr::mutate(route_geometry = geometry)
``` 

#### path() içinde bu geometry verilerini kullan

##### opt01: spatialLines df içinde kaydet

##### opt02: path() fonksiyonuyla spatyel formata çevir kullanım sırasında

Edit `~/projects/itr/peyman/pvrp/scripts/write_route_geometry.R`

Önce tüm data için geometry verisini oluşturalım ilk adımda.

Bunu raporlama sırasında yapalım. yani trips_with_costs.tsv dosyasını oluştururken:

		trips_with_costs = function(routes, customers, od_table, end_points, points) { <url:/Users/mertnuhoglu/projects/itr/peyman/pvrp/scripts/write_performance_reports.R#tn=trips_with_costs = function(routes, customers, od_table, end_points, points) {>

Bunun için bir main fonksiyonu oluşturalım

``` r
write_route_geometry()
``` 

Dosyayı okuyalım şimdi. `trips_with_costs` yerine artık `trips_with_route_geometry` okuyalım.

###### önceki runlar için trips_with_route_geometry oluşturma

####### Result

Ancak önce mevcut rapor dosyaları için `trips_with_route_geometry` oluşturmalıyım.

Nasıl yapacağız? raporlamayı yaptığımız gibi mi?

routes.csv dosyasını kopyalayıp tekrar main fonksiyonunu çalıştır.

01: Önce routes.csv dosyasını oluştur.

``` bash
./main_rotalar_to_routes_algo.R
./main_routes_algo_to_routes_normal.R
  ##> /Users/mertnuhoglu/projects/itr/peyman/pvrp_data/out/report_20190526_00/routes_algo.csv
cp /Users/mertnuhoglu/projects/itr/peyman/pvrp_data/out/report_20190526_00/routes_algo.csv ~/projects/itr/peyman/pvrp/routes.csv
``` 

02: Şimdi trips_with_costs.csv dosyasını oluştur

``` r
source("main_reports_funs.R")
main_optimized_routes()
``` 

03: Şimdi trips_with_route_geometry dosyasını oluştur

``` r
source("write_route_geometry.R")
write_route_geometry()
``` 

Output: `~/projects/itr/peyman/pvrp/out/trips_with_route_geometry.tsv`

####### Logs

######## Error: cannot open file '1_1371.json': No such file or directory

Dosya burada, neden açamadı?

		j0 = rjson::fromJSON(file=f)

path yanlış

##### trips_with_route_geometry verisini kullan path() içinde

Result: 

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/df_sf/ex03b06.R`

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/ex09.R`

###### Logs


``` r
c0 = readr::read_tsv("trips_with_route_geometry.tsv") %>%
	dplyr::select(from_point_id, to_point_id, from_lng, from_lat, to_lng, to_lat, route_geometry)

p0 = decode(c0$route_geometry[1], multiplier=1e5)
c4 = c0 %>%
	dplyr::mutate(path = decode(route_geometry, multiplier=1e5))
``` 

Şu satır çalışıyor:

``` r
p0 = decode(c0$route_geometry[1], multiplier=1e5)
``` 

Fakat bu çalışmıyor:
 
``` r
c4 = c0 %>%
	dplyr::mutate(path = decode(route_geometry, multiplier=1e5))
``` 

####### Error: Column `path` is of unsupported type S4

``` r
c4 = c0 %>%
	dplyr::mutate(path = decode(route_geometry, multiplier=1e5))
``` 

####### decode sf objesi dönsün

Adım adım debug ederek gidelim

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/decode_sf/ex01.R`

Kullanımı: `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/ex10.R`

####### normal df ile sf objelerini nasıl birleştireceğim?

Result: 

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/df_sf/ex03b06.R`

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/df_sf/ex01.R`

önce bir vektör oluşturalım

opt01:

``` r
p0 = decode_sf(c0$route_geometry, multiplier=1e5)
``` 

bu şekilde olmuyor. 

opt02: örnekleri incele

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/df_sf/geo_data.R`

``` r
source("geo_data.R")
``` 

Use `st_as_sf` in `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/df_sf/ex02a01.R`

######## opt03: 

Plan:

		addPolylines(data=df$geometry)
		df = st_as_sf(d0)
		d0$geom = st_sfc(rg)
		rg = decode(d0$route_geometry)

######### Follow googlePolylines tutorial

Follow https://cran.r-project.org/web/packages/googlePolylines/vignettes/sfencode.html

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/df_sf/ex03a01.R`

########## Assign it to a df column

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/df_sf/ex03a02.R`

``` r
p0 = decode(polylines)
st_sfc(p0)
``` 

Bu çalışmadı

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/df_sf/ex03a03.R`

Doğrudan encoded datayı kullan `addPolylines` içinde

opt02: doğrudan st_as_sfc(route_geometry) kullan

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/df_sf/ex03a04.R`

opt05: follow https://gis.stackexchange.com/questions/253898/adding-a-linestring-by-st-read-in-shiny-leaflet

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/df_sf/ex03a05.R`

``` r
library(sf)
library(leaflet)

badLine <- st_sfc(st_linestring(matrix(1:32, 8)), st_linestring(matrix(1:8, 2)))

head(badLine)

  ##> Geometry set for 2 features 
  ##>     geometry type:  LINESTRING
  ##>     dimension:      XYZM
  ##>     bbox:           xmin: 1 ymin: 3 xmax: 8 ymax: 16
  ##>     epsg (SRID):    NA
  ##>     proj4string:    NA
  ##>     LINESTRING ZM (1 9 17 25, 2 10 18 26, 3 11 19 2...
  ##>     LINESTRING ZM (1 3 5 7, 2 4 6 8)

  ##> # attempt map; will fail
leaflet() %>%
	addTiles() %>%
	addPolygons(data = badLine)

  ##> Error in if (length(nms) != n || any(nms == "")) stop("'options' must be a fully named list, or have no names (NULL)") : 
  ##>   missing value where TRUE/FALSE needed

  ##> # try again!

  ##> # drop Z and M dimensions from badLine
goodLine <- st_zm(badLine, drop = T, what = "ZM")

  ##> # map; will plot successfully!
leaflet() %>%
  addTiles() %>%
  addPolygons(data = goodLine)

class(goodLine)
  ##> [1] "sfc_LINESTRING" "sfc"
``` 

Demek ki `sfc` çalışıyor. O zaman encoded polyline objelerini sfc'ye nasıl çevireceğim sorun o.

########## opt08: encoded_polyline -> [decode] -> dataframe of lat lon -> ... -> sfc

Follow https://gis.stackexchange.com/questions/222978/lon-lat-to-simple-features-sfg-and-sfc-in-r

01: dataframe'den bir sf tablosu oluşturma:

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/df_sf/ex03b01.R`

``` r
DT <- data.table(
                 place=c("Finland", "Canada", "Tanzania", "Bolivia", "France"),
                 longitude=c(27.472918, -90.476303, 34.679950, -65.691146, 4.533465),
                 latitude=c(63.293001, 54.239631, -2.855123, -13.795272, 48.603949))
DT_sf = st_as_sf(DT, coords = c("longitude", "latitude"), 
                 crs = 4326, agr = "constant")
``` 

Bununla noktaları tek tek oluşturuyorum. Peki MultiLine nasıl oluşturacağım?

02: sfg sfc ve sf evrilişi

1. `st_point` ile sfg oluştur
2. `st_sfc` ile `sfg` vektörünü `sfc` kolonuna çevir
3. `st_sf` ile sfc kolonunu bir df tablosuna koy

Follow https://cran.r-project.org/web/packages/sf/vignettes/sf1.html

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/df_sf/ex03b02.R`

03: kendi verimizle bu işlemleri tekrarlamak

decode çıktısı bir df fakat st_point türü fonksiyonlar matrix bekliyor. bu yüzden önce df'yi matrix'e çevirmeliyiz

xy sıralaması olmalı dolayısıyla lon önce gelmeli

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/df_sf/ex03b03.R`

04: Refactor et

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/df_sf/ex03b04.R`

########## 05: Tüm tablo için yapalım

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/df_sf/ex03b05.R`

########### Logs

``` r
c0 = readr::read_tsv("../trips_with_route_geometry.tsv") %>%
	dplyr::select(from_point_id, to_point_id, from_lng, from_lat, to_lng, to_lat, route_geometry) %>%
	dplyr::mutate(decoded = googlePolylines::decode(route_geometry))

c0$decoded %>% length
  ##> [1] 3000
c0 %>% nrow
  ##> [1] 3000
c0[1,]$decoded
  ##> [[1]]
  ##>          lat      lon
  ##> 1   40.89088 29.20862
  ##> 2   40.89102 29.20844

sfg01 = lapply(c0$decoded, function(decoded_df) {
	decoded_df %>%
		dplyr::select(lon, lat) %>%
		data.matrix() %>%
		st_linestring() 
})
``` 

``` r
> class(sfg01)
[1] "list"
> class(sfg01[[1]])
[1] "XY"         "LINESTRING" "sfg"
``` 

Bir şekilde bu her bir list öğesini sfc'ye dönüştürüp hepsini bir kolon haline getirip, c0 df'sine eklemeliyim şuna benzer şekilde:

``` r
c0$geom = sfc_geom
c1 = st_sf(c0)
``` 

opt01: sfg objeleri bir vektör olmuyor mu?

``` r
> sfg02 = unlist(sfg01)
> class(sfg02)
  ##> [1] "numeric"
> sfg02 %>% head
  ##> [1] 29.20862 29.20844 29.20823 29.20798 29.20778 29.20748
``` 

opt02: list sfg nasıl sfc kolonuna çevrilir örneklere bak

``` r
sfg03 = unlist(sfg01)
		st_sfc() 
``` 

opt03: do.call rbind kullan 

`df <- do.call(rbind, my_list)`

``` r
sfg03 = do.call(rbind, sfg01)
``` 

############ opt04: önce sf'ye çevir sonra rbind yap

``` r
sfg05 = lapply(c0$decoded, function(decoded_df) {
	decoded_df %>%
		dplyr::select(lon, lat) %>%
		data.matrix() %>%
		st_linestring() %>%
		st_sfc() %>%
		st_sf()
})
sfg06 = do.call(rbind, sfg05)
  ##>                          geometry
  ##> 1  LINESTRING (29.20862 40.890...
  ##> 2  LINESTRING (29.13966 40.993...
``` 

Şimdi bunu c0 kolonlarıyla nasıl birleştireceğiz?

opt01: cbind kullan

opt02: yeni tablo oluştur

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/df_sf/ex03b06.R`

#### geometry datasını kaydet

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/ex11.R`

opt01: csv

``` r
st_write(c1, "trips_with_geometry01.csv")
  ##> from_point_id,to_point_id,from_lng,from_lat,to_lng,to_lat
  ##> 1,1371,29.208498,40.890795,29.13966,40.99401
``` 

csv formatı geometrik veriyi içermiyor. 

opt02: shp

``` r
st_write(c1, "trips_with_geometry02.shp")
``` 

Bu da okunabilir bir format değil.

opt03: wkt ve csv

``` r
c2 = c1 %>%
	dplyr::mutate(geometry_wkt = st_as_text(geometry))
st_write(c2, "trips_with_geometry04.csv")
``` 

Bu okunabilir formatta

``` csv
from_point_id,to_point_id,from_lng,from_lat,to_lng,to_lat,geometry_wkt
1,1371,29.208498,40.890795,29.13966,40.99401,"LINESTRING (29.20862 40.89088, 29.20844 40.89102, ...)"
``` 

#### geometry datasını csv dosyasından oku

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/ex12.R`

``` r
c3 = st_read("trips_with_geometry04.csv")
``` 

### pmap'te gerçek veri üzerinde bunu kullan şimdi

#### test edelim

##### opt01: sade bir dosya içinde rotaları çizdirmeyi test et

Daha önceki örnek script: `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex04.R`

Check: `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/ex13.R`

Önce wkt'yi sfg'ye çevir: 

``` r
c3 = st_read("trips_with_geometry04.csv") 

gwkt = c3$geometry_wkt[1]
sfc0 = st_as_sfc(gwkt)

m <- leaflet(width="100%") %>% 
  addTiles()  %>% 
  addPolylines(data = sfg0[[1]], color = "#AC0505", opacity=1, weight = 3) 
m
``` 

sf objesine ekle bunu:

Check `~/projects/itr/peyman/pmap/doc/study/ex/performans_iyilestirme_leaflet_20190629/ex14.R`

``` r
c3 = st_read("trips_with_geometry04.csv") %>%
	dplyr::mutate(geom = st_as_sfc(geometry_wkt)) %>%
	st_sf()

m <- leaflet(width="100%") %>% 
  addTiles()  %>% 
  addPolylines(data = c3$geom[1], color = "#AC0505", opacity=1, weight = 3) 
``` 

#### trips_with_geometry04.csv dosyasını raporların içine koy

		twrg = trips_with_route_geometry(trips_w_curl_cmd) <url:/Users/mertnuhoglu/projects/itr/peyman/pvrp/scripts/write_route_geometry.R#tn=twrg = trips_with_route_geometry(trips_w_curl_cmd)>

Check `~/projects/itr/peyman/pvrp/scripts/write_route_geometry.R`

`write_route_geometry` fonksiyonunu test et

``` r
source("write_route_geometry.R")
``` 

##### refactoring: trips_with_route_geometry fonksiyonunu sadeleştir

curl_cmd.sh dosyasına bağımlılık olmasın:

#### get_routes.R üzerinde deneyelim

		#twc = readr::read_tsv(glue::glue("{PEYMAN_PROJECT_DIR}/pvrp_data/out/{plan_name}/trips_with_route_geometry.tsv")) <url:/Users/mertnuhoglu/projects/itr/peyman/pmap/R/get_routes.R#tn=#twc = readr::read_tsv(>

##### test get_routes.R ile rota çizimi

``` r
PEYMAN_PROJECT_DIR = Sys.getenv("PEYMAN_PROJECT_DIR")
plan_name = "report_20190526_00"
routes = get_routes_verbal(plan_name)
``` 

Error: salesman_id missing

##### test shiny app

###### Error: Warning: Error in <Anonymous>: All sub-lists in "choices" must be named.

			113: stop
			112: <Anonymous>
			111: mapply
			110: choicesWithNames
			109: <Anonymous>
			108: mapply
			107: choicesWithNames
			106: shiny::selectInput
			 97: renderUI [/Users/mertnuhoglu/projects/itr/peyman/pmap/R/route_navigator.R#70]

Muhtemelen neden:

		result$init_sqn_choices = get_routes_by_smi_wkd(result$init_routes_all, result$init_smi_selected, result$init_wkd_selected)

Test scriptini çalıştır

Fix:

		result$init_sqn_choices = get_routes_by_smi_wkd(result$init_routes_all, result$init_smi_selected, result$init_wkd_selected)$sequence_no

###### Error: Warning: Error in [[<-.data.frame: replacement has 2 rows, data has 0

message:

		Reading layer `trips_with_route_geometry' from data source `/Users/mertnuhoglu/projects/itr/peyman/pvrp_data/out/report_20190526_00/trips_with_route_geometry.csv' using driver `CSV'
		Warning: no simple feature geometries present: returning a data.frame or tbl_df
		Warning in Ops.factor(sequence_no, sqn) : ‘<=’ not meaningful for factors
		Warning: Error in [[<-.data.frame: replacement has 2 rows, data has 0
			53: stop
			52: [[<-.data.frame
			48: $<-.sf
			46: make_map [/Users/mertnuhoglu/projects/itr/peyman/pmap/R/get_routes.R#27]

####### test scriptinden debug et make_map fonksiyonunu

Error:

		Error in validateCoords(lng, lat, funcName) :
			addAwesomeMarkers requires numeric longitude/latitude values

Code:

		m <- leaflet::leaflet(width="100%") %>% 
			leaflet::addTiles() %>%
			leaflet::addAwesomeMarkers(lng=orig$lng, lat=orig$lat)

faktör olarak okumuş lng ve lat değerlerini

``` r
> orig$lng
[1] 29.208498
2627 Levels: 29.00658 29.00831 29.01
``` 

Dosyanın okunduğu yer:

``` r
twc = sf::st_read(glue::glue("{PEYMAN_PROJECT_DIR}/pvrp_data/out/{plan_name}/trips_with_route_geometry.csv")) 
str(twc)
  ##> 'data.frame':   3000 obs. of  20 variables:
  ##>  $ salesman_id  : Factor w/ 27 levels "100","101","12",..: 11 11 11 11 11 11 11 11 11 11 ...
  ##>  $ week_day     : Factor w/ 6 levels "0","1","2","3",..: 1 1 1 1 1 1 1 1 1 1 ...
  ##>  $ customer_id  : Factor w/ 2702 levels "0","100268","100786",..: 1 854 1919 366 1295 2308 2289 1434 2343 53 ...
``` 

Fix: `readr` kullan okumada

``` r
twc = readr::read_csv(glue::glue("{PEYMAN_PROJECT_DIR}/pvrp_data/out/{plan_name}/trips_with_route_geometry.csv")) 
str(twc)
  ##> Classes ‘spec_tbl_df’, ‘tbl_df’, ‘tbl’ and 'data.frame':    3000 obs. of  20 variables:
  ##>  $ salesman_id  : num  7 7 7 7 7 7 7 7 7 7 ...
  ##>  $ week_day     : num  0 0 0 0 0 0 0 0 0 0 ...
``` 

###### Error in is.finite: default method not implemented for type 'list'

		Warning: Error in is.finite: default method not implemented for type 'list'
			 82: output$routes
				2: shiny::runApp
				1: run_app [/Users/mertnuhoglu/projects/itr/peyman/pmap/R/route_navigator.R#218]

		number of items to replace is not a multiple of replacement length

opt01: path() fonksiyonuyla dene

Problem table output sırasında meydana geliyor 

				, shiny::tableOutput("routes")

Fix: geometry kolonunu kaldır çıktıdan:

		output$routes_table = renderTable({  dplyr::select(state$routeSS, -geometry) })

###### Error: in <-: number of items to replace is not a multiple of replacement length

opt02: eski halini deneyebilir miyim?

Bu ikisi çalışıyor:

		twc = readr::read_tsv(glue::glue("{PEYMAN_PROJECT_DIR}/pvrp_data/out/{plan_name}/trips_with_costs.tsv")) 
		twc = readr::read_csv(glue::glue("{PEYMAN_PROJECT_DIR}/pvrp_data/out/{plan_name}/trips_with_route_geometry.csv")) 

Bunda hata veriyor:

		twc = readr::read_csv(glue::glue("{PEYMAN_PROJECT_DIR}/pvrp_data/out/{plan_name}/trips_with_route_geometry.csv")) %>%
			dplyr::mutate(geometry = sf::st_as_sfc(geometry_wkt)) %>%
			sf::st_sf()

Hata tetikleyici:

			sf::st_sf()

Muhtemel neden:

sf objesi renderTable ile çalışmıyor, çünkü sf'in metadatası olan veriler renderTable ile uyumlu çalışmıyor olmalı.

Fix: sf'i tekrar düz df'e çevir

		output$routes_table = renderTable({ 
			r0 = dplyr::select(state$routeSS, salesman_id, week_day) 
			sf::st_geometry(r0) <- NULL
			r0
		})

### shiny'nin aşırı hızlı request göndermesinden yavaşlık kaynaklanıyor olabilir mi?

#### test fonksiyonundan taklit et

Ref: 

		test_that("make_map with multiple days and salesman", <url:/Users/mertnuhoglu/projects/itr/peyman/pmap/tests/testthat/test-get_routes.R#tn=make_map with multiple days and salesman>

Yavaşlık burada:

``` bash
map = make_map(routes, coloring_select)
``` 

bug reproduce: aynı anda bir satıcı ekleyip başka bir satıcıyı çıkartınca sorun çıkıyor

### bug: aynı anda satıcı ekleyip çıkartınca sonsuz döngüye giriyor

