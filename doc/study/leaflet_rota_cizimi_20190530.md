
# leaflet ile rota çizimi

## Logs

### Örnek shiny uygulaması: 086-bus-dashboard

#### shiny-examples nasıl çalıştırılıyor?

https://github.com/rstudio/shiny-examples

``` r
if (!require('shiny')) install.packages("shiny")
shiny::runGitHub("shiny-examples", "rstudio", subdir = "001-hello")
``` 

``` r
install.packages("shinydashboard")
``` 

``` r
wget http://www.bart.gov/dev/schedules/google_transit.zip
``` 

``` r
dir.create("rds", showWarnings = FALSE)

datafiles <- c("shapes.txt", "trips.txt")
for (datafile in datafiles) {
  infile <- file.path("/Users/mertnuhoglu/data/google_transit/", datafile)
  outfile <- file.path("rds", sub("\\.txt$", ".rds", datafile))

  cat("Converting ", infile, " to ", outfile, ".\n", sep = "")

  obj <- read.csv(infile, stringsAsFactors = FALSE)
  saveRDS(obj, outfile)
}
``` 

``` bash
cd /Users/mertnuhoglu/codes/rr/shiny-examples/086-bus-dashboard
``` 

``` r
shiny::runApp(".")
``` 

#### Error

Warning: Error in n: argument "x" is missing, with no default

		 96: get_route_shape [/Users/mertnuhoglu/codes/rr/shiny-examples/086-bus-dashboard/server.R#30]
		 95: func [/Users/mertnuhoglu/codes/rr/shiny-examples/086-bus-dashboard/server.R#179]
 
``` r
shiny::runApp(".")
``` 

Warning: Error in n: argument "x" is missing, with no default

		 96: get_route_shape [/Users/mertnuhoglu/codes/rr/shiny-examples/086-bus-dashboard/server.R#30]
		 95: func [/Users/mertnuhoglu/codes/rr/shiny-examples/086-bus-dashboard/server.R#179]

Fix:

    summarise(n = n()) %>%
		->
    summarise(n = dplyr::n()) %>%

### Article: Routing in R using the open source routing machine (OSRM)

https://cmhh.github.io/post/routing/

``` r
install.packages("rjson")
install.packages("bitops")
install.packages("sp")
``` 

``` r
o <- origin$results[[1]]$geometry$location
d <- destination$results[[1]]$geometry$location
(url <- paste0("http://router.project-osrm.org/route/v1/driving/", 
   o$lng,",",o$lat,";",d$lng,",",d$lat,"?overview=full"))
[1] "http://router.project-osrm.org/route/v1/driving/175.0845498,-41.1250097;174.7811653,-41.2756572?overview=full"
route <- fromJSON(file=url)
``` 

Response:

``` r
route$routes[[1]]$duration
[1] 1728.5
route$routes[[1]]$distance
[1] 34267
route$routes[[1]]$geometry
[1] "hf_zFufsk`@M?O?QCoAKC\\GV..."
``` 

The route geomertry is stored in [encoded polyline algorithm format](https://developers.google.com/maps/documentation/utilities/polylinealgorithm).

Convert the encoded route to a SpatialLines object:

``` r
decode <- function(str, multiplier=1e5){
   
   if (!require(bitops)) stop("Package: bitops required.")
   if (!require(sp)) stop("Package: sp required.")
   
   truck <- 0
   trucks <- c()
   carriage_q <- 0
   
   for (i in 0:(nchar(str)-1)){
      ch <- substr(str, (i+1), (i+1))
      x <- as.numeric(charToRaw(ch)) - 63
      x5 <- bitShiftR(bitShiftL(x, 32-5), 32-5)
      truck <- bitOr(truck, bitShiftL(x5, carriage_q))
      carriage_q <- carriage_q + 5
      islast <- bitAnd(x, 32) == 0
      if (islast){
         negative <- bitAnd(truck, 1) == 1
         if (negative) truck <- -bitShiftR(-bitFlip(truck), 1)/multiplier
         else truck <- bitShiftR(truck, 1)/multiplier
         trucks <- c(trucks, truck)
         carriage_q <- 0
         truck <- 0
      }
   }
   lat <- trucks[c(T,F)][-1]
   lng <- trucks[c(F,T)][-1]
   res <- data.frame(lat=c(trucks[1],cumsum(lat)+trucks[1]), 
                     lng=c(trucks[2],cumsum(lng)+trucks[2]))

   coordinates(res) <- ~lng+lat
   proj4string(res) <- CRS("+init=epsg:4326")
   return(SpatialLines(list(Lines(Line(res), 1)), CRS("+init=epsg:4326")))
}
par(mar=par()$mar-c(1,0,2.5,0), cex=0.8)
path <- decode(route$routes[[1]]$geometry, multiplier=1e5)
plot(path); axis(1); axis(2); box()
``` 

Make a leaflet map:

``` r
  #make a string to nicely label the route
s <- route$routes[[1]]$duration
kms <- round(route$routes[[1]]$distance/1000, 1)
routelabel <- paste0(s%/%60, "m ", s%%60, "s , ", kms, "kms")

  #create a basic map
library(leaflet)
m <- leaflet(width="100%") %>% 
  addTiles()  %>% 
  addPolylines(data=path, popup=routelabel, color = "#000000", opacity=1, weight = 3) %>%
  addMarkers(lng=o$lng, lat=o$lat, popup=origin$results[[1]]$formatted_address) %>%
  addMarkers(lng=d$lng, lat=d$lat, popup=destination$results[[1]]$formatted_address)
m
``` 

#### ex01: makaledeki uygulamayı yapma

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex01.R`

#### ex04: Kendi noktalarımızla rota çizimi

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex04.R`

Best solution so far.

### Article: rCarto/osrm

https://github.com/rCarto/osrm

https://rgeomatic.hypotheses.org/854

https://cran.r-project.org/web/packages/osrm/osrm.pdf

``` r
install.packages("osrm")
install.packages("cartography")
``` 

#### Setup OSRM Settings

Put `OSRM_SERVER` into `.bashrc`

``` bash
export OSRM_SERVER=35.204.111.216:5000
``` 

``` r
library(osrm)
library(sf)
library(cartography)
  ##> osrm_server = 35.204.111.216:5000
osrm_server = Sys.getenv("OSRM_SERVER")
options(osrm.server = glue::glue("http://{osrm_server}/"), osrm.profile = "driving")
``` 

``` r
ps = "
lng,lat
29.208498,40.890795
29.24633,40.9894
29.08812,40.99462
29.233,40.87585
"
cs <- read.csv(text=ps, header = T)
``` 

``` r
  # Travel path between points - output a SpatialLinesDataFrame
route <- osrmRoute(src=c("Depo", cs$lng[1], cs$lat[1]),
                    dst = c("Market 01", cs$lng[2], cs$lat[2]),
                    sp = TRUE, overview = "full")
``` 

opt01:

``` r
osm <- getTiles(x = route, crop = TRUE, type = "osm", zoom = 13)
tilesLayer(osm)
plot(st_geometry(route), lwd = 4, add = TRUE)
plot(st_geometry(route), lwd = 1, col = "white", add = TRUE)
``` 

Error:

opt02:

``` r
  # Display the path
plot(com[c(1,4),3:4], asp =1, col = "red", pch = 20, cex = 1.5)
plot(route, lty = 1,lwd = 4, add = TRUE)
plot(route, lty = 1, lwd = 1, col = "white", add=TRUE)
text(com[c(1,4),3:4], labels = com[c(1,4),2], pos = 2)
``` 

### Tüm rotaları çizdirme

#### ex05: Birden çok noktayı koyma

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex05.R`

``` r
route = function(orig, dest) {
	url = glue::glue("http://{osrm_server}/route/v1/driving/{orig$lng},{orig$lat};{dest$lng},{dest$lat}?overview=full")
	return(fromJSON(file=url))
}

way = function(route) {
	return(decode(route$routes[[1]]$geometry, multiplier=1e5))
}

p1 = cs[1,]
p2 = cs[2,]
p3 = cs[3,]
r1 = route(p1, p2)
w1 = way(r1)
r2 = route(p2, p3)
w2 = way(r2)

m <- leaflet(width="100%") %>% 
  addTiles()  %>% 
  addPolylines(data = w1, popup = route_label(r1), color = "#AC0505", opacity=1, weight = 3) %>%
  addPolylines(data = w2, popup = route_label(r2), color = "#AC0505", opacity=1, weight = 3) %>%
  addMarkers(lng=p1$lng, lat=p1$lat, popup="Depo") %>%
  addMarkers(lng=p2$lng, lat=p2$lat, popup="Market 01") %>%
  addMarkers(lng=p3$lng, lat=p3$lat, popup="Market 02")
m
``` 

#### ex06: Noktaları bir fonksiyon haline getirme

##### Error: All columns in a tibble must be 1d or 2d objects:

``` r
rs = dplyr::tibble( path = w1, route = r1)
``` 

		Error: All columns in a tibble must be 1d or 2d objects:
		* Column `path` is SpatialLines

#### ex07: SpatialLines ile dataframe oluşturma

https://gis.stackexchange.com/questions/163286/how-do-i-create-a-spatiallinesdataframe-from-a-dataframe

#### ex08: 2d object as a column in a tibble

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex08.R`

``` r
library(dplyr, warn.conflicts = FALSE)

df <- data.frame(x1 = rep(1:3, times = 3), x2 = 1:9)
df$x3 <- df %>% mutate(x3 = x2)
as_tibble(df)
df$x3
  ##>      x1    x2 x3$x1   $x2   $x3
  ##>   <int> <int> <int> <int> <int>
  ##> 1     1     1     1     1     1
  ##> 2     2     2     2     2     2
  ##> 3     3     3     3     3     3
  ##> 4     1     4     1     4     4
  ##> 5     2     5     2     5     5
  ##> 6     3     6     3     6     6
  ##> 7     1     7     1     7     7
  ##> 8     2     8     2     8     8
  ##> 9     3     9     3     9     9
df$x3
  ##>   x1 x2 x3
  ##> 1  1  1  1
  ##> 2  2  2  2
  ##> 3  3  3  3
  ##> 4  1  4  4
  ##> 5  2  5  5
  ##> 6  3  6  6
  ##> 7  1  7  7
  ##> 8  2  8  8
  ##> 9  3  9  9
``` 

#### ex09: for loop ile leaflet addPolylines çağır

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex09.R`

``` r
m <- leaflet(width="100%") %>% 
  addTiles()  

for (i in 1:(nrow(cs) - 1)) {
	p1 = cs[i, ]
	p2 = cs[i+1, ]
	rt = route(p1, p2)
	ph = path(rt)
	m = m %>% 
		addPolylines(data = ph, popup = route_label(rt), color = "#AC0505", opacity=1, weight = 3) %>%
		addMarkers(lng=p1$lng, lat=p1$lat, popup=glue("Market {i}"), label = glue("{i}")) 
}
m = m %>%
  addMarkers(lng=p2$lng, lat=p2$lat, popup=glue("Market {i+1}"), label = glue("{i+1}")) 
m
``` 

#### ex10: color palet kullanımını test et

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex10.R`

``` r
pal <- colorNumeric(c("red", "green", "blue"), 1:10)
pal(1:10)
  ##>  [1] "#FF0000" "#EB7000" "#D0A100" "#AAC900" "#6AEE00" "#52E74B" "#77B785" "#7C87B0" "#6754D8" "#0000FF"
``` 

#### ex11: renk paletini rotalarda kullan

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex11.R`

``` r
no_routes = nrow(cs) - 1
pal <- colorNumeric(c("red", "green", "blue"), 1:no_routes)
col = pal(1:no_routes)
...
		addPolylines(data = ph, popup = route_label(rt), color = col[i], opacity=1, weight = 3) %>%
``` 

#### ex12: bir satıcının tüm rotalarını çizdir

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex12.R`

``` r
twc = readr::read_tsv("~/projects/itr/peyman/pvrp/out/trips_with_costs.tsv")

rt07 = twc %>%
	dplyr::filter(salesman_id == 7 & week_day == 0) %>%
	dplyr::select(
		lat = from_lat
		, lng = from_lng
	)
depot = rt07[1, ]
cs = dplyr::bind_rows(rt07, depot)
``` 

### Uygulama haline getirme

#### ex13: leaflet shiny basic app

https://rstudio.github.io/leaflet/shiny.html

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex13.R`

Run from R:

``` r
shinyApp(ui, server)
``` 

Run from terminal:

``` bash
Rscript ex13.R
``` 

#### ex14: leaflet height full screen

https://stackoverflow.com/questions/36469631/how-to-get-leaflet-for-r-use-100-of-shiny-dashboard-height

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex14.R`

#### ex15: Kendi rotalarımızı bu appte gösterelim

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex15.R`

#### ex16: Temel bir shiny uygulaması

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex16.R`

Her yerden erişilebilir olması için: `host="0.0.0.0"` olmalı

``` r
runApp(shinyApp(ui, server), host="0.0.0.0",port=5050)
``` 

### Navigatör özellikleri

#### Filtreleme özellikleri

##### ex17: basit bir filtreleme uygulaması örneği

https://stackoverflow.com/questions/50128349/filtering-leaflet-map-data-in-shiny

##### ex18: sadece sözel bilgiyi kullanarak kendi rotamızı filtreleme

Datayı hazırla verbal df olarak:

###### Error: nothing happens

``` r
source("get_routes.R")

routes = get_routes_verbal()
get_route_for_sequence_no(routes, 2)
  ##> all rows
``` 

``` r
sequence_no = 2
routes %>%
	dplyr::filter(sequence_no %in% c(sequence_no, sequence_no + 1))
  ##> all rows
``` 

``` r
routes %>%
	dplyr::filter(sequence_no %in% c(2,3))
  ##> two rows only
c(sequence_no, sequence_no + 1)
``` 

``` r
sequence_no = 2
sq = c(sequence_no, sequence_no + 1)
  ##> [1] 2 3
routes %>%
	dplyr::filter(sequence_no %in% sq)
  ##> two rows only
``` 

``` r
routes %>%
	dplyr::filter(sequence_no %in% (c(sequence_no, sequence_no + 1)))
``` 

Cause: sequence_no is implicit variable. `c(sequence_no, sequence_no + 1)` is interpreted as `routes$sequence_no`.

###### Error: non-numeric argument to binary operator

		Warning: Error in +: non-numeric argument to binary operator
			97: get_route_for_sequence_no [get_routes.R#47]

``` r
get_route_for_sequence_no = function(routes, sequence_no) {
	sq = c(sequence_no, sequence_no + 1)
	routes %>%
		dplyr::filter(sequence_no %in% sq)
}
get_route_for_sequence_no(routes, 2)
  ##>     lat   lng sequence_no
  ##>   <dbl> <dbl>       <dbl>
  ##> 1  41.0  29.0           2
  ##> 2  41.0  29.0           3
``` 

opt01: return data.frame instead of tibble

``` r
get_route_for_sequence_no = function(routes, sequence_no) {
	sq = c(sequence_no, sequence_no + 1)
	routes %>%
		dplyr::filter(sequence_no %in% sq) %>%
		as.data.frame()
}
``` 

Same error.

opt02: create it as data.frame from start

Location:

``` r
get_route_for_sequence_no = function(routes, seq) {
	print(seq)
  ##> 2
	print(str(seq))
  ##>  num 2
	seq + 1
``` 

Warning: Error in +: non-numeric argument to binary operator

Wrap all input data inside `reactive`

Experiment in `ex21: non-numeric argument problemi <url:/Users/mertnuhoglu/projects/itr/peyman/pmap/doc/study/leaflet_rota_cizimi_20190530.md#tn=ex21: non-numeric argument problemi>`

Use `as.numeric`

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex18a.R`

Still the same error.

Clean the code to isolate the problem. 

Debug with `class`

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex18b.R`

``` r
get_route_for_sequence_no = function(routes, seq) {
	print(class(seq))
  ##> [1] "reactiveExpr" "reactive"
``` 

Don't use `reactive`

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex18c.R`

``` r
  output$routes <- renderTable({
		get_route_for_sequence_no(routes, as.numeric(input$sequence_no))
		...
get_route_for_sequence_no = function(routes, seq) {
	print(class(seq))
  ##> [1] "numeric"
``` 

Works. 

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex18d.R`

Works. 

##### ex19: kendi rotalarımızı bir tablo ve widgetla birlikte gösterme

Sadece verbal data. 

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex19.R`

##### ex21: non-numeric argument problemi

Problemi en basit haliyle reproduce edelim.

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex21.R`

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex21a.R`

Seçilen öğeyi print et:

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex21b.R`

Seçilen öğeyle bir işlem yap

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex21c.R`

Error:

		Warning: Error in +: non-numeric argument to binary operator
			96: renderText [#3]

Debug the problem with `class`

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex21d.R`

``` r
		print(class(input$numara))
		##> character
``` 

Convert to numeric

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex21e.R`

Problem solved.

##### ex22: sözel bilgiye geometriyi de ekle

Previous step: ex18

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex22.R`

Test `get_route_geometry`

``` r
t0 = get_route_for_sequence_no(routes, 2)
get_route_geometry(t0, 2)
``` 

It works.

`render` it in shiny

##### ex23: sequence_no değişince haritadaki rota da değişsin

Use `reactive` expression

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex23.R`

#### Navigasyon özellikleri

##### Bir satıcının gün içindeki rotaları arasında

###### ex24: iki buton koy. sequence_no dolaş.

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex24.R`

Counter örneği: https://gist.github.com/aagarw30/69feeeb7e813788a753b71ef8c0877eb as `counter`

###### ex25: bir satıcının rotalarını dolaş

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex25.R`

###### ex26: hızlı zıplama select ile

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex26.R`

####### Error: başlangıçta NA dönüyor selectInput

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex26a.R`

Default value belirt

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex26b.R`

``` r
      , selectInput("sequence_no", 'Rota sırası', choices = routes$sequence_no, selected = "0")
``` 

Map olmadan düzeni test et:

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex26c.R`

``` r
	observeEvent(input$sequence_no, {
		seq_counter$seq_value = as.numeric(input$sequence_no)
		#as.numeric(input$sequence_no)
	})
	...
  route_input <- reactive({
		get_route_for_sequence_no(routes, 0)
	})
``` 

Başlangıç değeri: `NA` yine `seq_value` için

selectize = F ile test et:

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex26d.R`
 
Ok, çalıştı.

Haritayı da bağla.

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex26e.R`
 
###### ex27: selectInput da güncellensin butona basılınca

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex27.R`

``` bash
	observe({
		updateSelectInput(session, "sequence_no",
			selected = seq_counter$seq_value
	)})
``` 

Follow https://stackoverflow.com/questions/21465411/r-shiny-passing-reactive-to-selectinput-choices

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex27a.R`

##### Satıcılar arasında dolaşma

###### ex28: satıcı listesi ve rota listesi birlikte bulunsun

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex28.R`

Tüm satıcıları listele:

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex28a.R`

``` r
			, actionButton("prev_salesman", "Önceki Satıcı")
			, actionButton("next_salesman", "Sonraki Satıcı")
      , selectInput("salesman_id", "Satıcı", choices = get_salesman()$salesman_id %>% unique, selected = "7", selectize = F)
``` 

Refactoring: consistent names for all related variables

		seq_no
			textOutput("seq_no")
		selectInput("sequence_no",
		actionButton("prev_route", "Önceki")
		seq_counter <- reactiveValues(seq_value = 0) 

->

		seq_no_out
		seq_no_select
		seq_no_prev
		seq_no_counter -> state
		seq_value -> seq_no

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex28b.R`

Salesman değişince haritadaki rotalar da değişsin

Bu durumda `routes` objesi de reactive bir state olmalı

``` r
routes = get_routes_verbal()
``` 

->

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex28c.R`

`routes` tüm rotaları içersin. `filter()` yaparız her girdi eyleminde.

Mevcut hali yeniden üret:

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex28d.R`

`routes` tümüyle reaktif olsun:

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex28e.R`

Bu durumda öncelikle selectInput içindeki routes reaktif olmalı:

``` r
      , selectInput("sqn_select", "Rota sırası", choices = routes$sequence_no, selected = "0", selectize = F)
``` 

->

``` r
	observe({
		updateSelectInput(session, "sqn_select",
			choices = state$routes$sequence_no
			, selected = state$sqn
	)})
``` 

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex28f.R`

Satıcı seçilince, `routes` değişmeli.

Bunun için observeEvent kullan:

``` r
	observeEvent(input$smi_select, {
		state$smi = as.numeric(input$smi_select)
		state$routes = get_routes_by_smi_wkd(routes_all, state$smi, sqn_selected)
	})
  route_input = reactive({
		get_route_for_sequence_no(state$routes, state$sqn)
  })
``` 

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex28g.R`

Satıcı seçilince, rota sırası seçimi sıfırlansın.

``` r
	observeEvent(input$smi_select, {
		state$smi = as.numeric(input$smi_select)
		state$routes = get_routes_by_smi_wkd(routes_all, state$smi, sqn_selected)
		state$sqn = 0
	})
``` 

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex28h.R`

Satıcı dolaşma butonları da çalışsın

Önce salesman_no listesi oluşturalım

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex28i.R`

Unduplicate code for `smi` and `smn`

``` r
  smn_next_action <- eventReactive(input$smn_next, {
		state$smn = state$smn + 1
  })
	smn_next = reactive({
		state$smi = (dplyr::filter(salesman, salesman_no == state$smn))$salesman_id
		state$routes = get_routes_by_smi_wkd(routes_all, state$smi, sqn_selected)
		state$sqn = 0
	})
	observeEvent(smn_next, {
	})
``` 

Nothing happens. 

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex28j.R`

``` r
	refresh_salesman = function() {
		state$smi = (dplyr::filter(salesman, salesman_no == state$smn))$salesman_id
		state$routes = get_routes_by_smi_wkd(routes_all, state$smi, sqn_selected)
		state$sqn = 0
		return(state)
	}
	observeEvent(input$smn_next, {
		state$smn = state$smn + 1
		refresh_salesman()
	})
``` 

This works.

##### Günler arasında dolaşma

###### ex29: aynı satıcının farklı günleri arasında dolaşma

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex29.R`

Refactoring: `route_input` yerine bir stream ismi olsun aynı `route$` gibi.

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex29a.R`

``` r
  routeS = reactive({ get_route_for_sequence_no(state$routes, state$sqn) })
``` 

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex29b.R`

Yeni butonları ekle

Select öğesini de senkronize et

### Birikimsel Navigasyon 

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex30.R`

Önce `get_route_geometry` fonksiyonunu birikimsel harita üretecek şekilde güncelleyelim

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/get_routes_ex30.R`

``` r
get_routes_all = function(routes) {
	cs = routes
	no_routes = nrow(cs) - 1
	pal <- colorNumeric(c('#7b241c' , '#FF69B4' , '#d4efdf' , '#f39c12' , '#9b59b6' , '#5499c7'), 1:6)
	col = rep(pal(1:6), times = 1 + (no_routes / 6))

	m <- leaflet(width="100%") %>% 
		addTiles()  

	for (i in 1:no_routes) {
		p1 = cs[i, ]
		p2 = cs[i+1, ]
		rt = route(p1, p2)
		ph = path(rt)
		m = m %>% 
			addPolylines(data = ph, label = route_label(rt), color = col[i], opacity=1, weight = 3) %>%
			addMarkers(lng=p1$lng, lat=p1$lat, popup=glue("Market {i}"), label = glue("{i}")) 
	}
	m = m %>%
		addMarkers(lng=p2$lng, lat=p2$lat, popup=glue("Market {i+1}"), label = glue("{i+1}")) 
	return(m)
}
``` 

Test it:

``` r
source("get_routes_ex30.R")
routes_all = get_routes_verbal()
r0 = get_routes_by_smi_wkd(routes_all, 7, 0)
get_routes_all(r0)
``` 

Bunu kullanalım. İlk etapta `get_routes_all()` fonksiyonuyla haritayı çizdirelim.

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex30a.R`

``` r
  output$map = renderLeaflet({ get_routes_all(routeS()) })
``` 

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex30b.R`

Şimdi birden çok rotayı state içinde tutalım. Rotalar `routeS` tarafından oluşturuluyor.

``` r
  routeS = reactive({ get_route_upto_sequence_no(state$routes, state$sqn) })
``` 

Fakat tüm rotaları döndürdü bize.

### Deploy et

tsv dosyalarını yukarı yükle.

``` bash
scp ~/gdrive/mynotes/prj/itr/iterative_mert/peyman/*.tsv itr01:~/peyman
``` 

``` bash
vim ~/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/pvrp.r
vim ~/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/get_routes_ex30.R
``` 

çalıştır:

``` r
source("ex30b.R")
``` 

### Error: Son adım olarak depo tüm rotalara ekleniyor

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex31.R`

`get_routes_by_smi_wkd()` tarafından ekleniyor:

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex31a.R`

``` r
get_routes_by_smi_wkd = function(routes, smi, wkd) {
	rt01 = routes %>%
		dplyr::filter(salesman_id == smi & week_day == wkd) 
	depot = rt01[1, ]
	cs = dplyr::bind_rows(rt01, depot)

	return(cs)
}
``` 

->

``` r
get_routes_by_smi_wkd = function(routes, smi, wkd) {
	rt01 = routes %>%
		dplyr::filter(salesman_id == smi & week_day == wkd) 

	return(rt01)
}
``` 

Şimdi de depo yok rotalarda. 

Cause: get_routes_verbal girdi veriyi trips_with_costs.tsv dosyasından alıyor. twc dosyasında her satırda bir path tarif ediliyor: from_point_id to_point_id ile. Dolayısıyla son adımda, dönüş noktası to_point_id ile tanımlanıyor. Bu yüzden bu dönüş noktası yeni bir nokta olarak eklenmiyor. 

Çözüm:

opt01: get_routes_verbal fonksiyonuna her bir rota dizisi için bir satır ekleyebilirim. ama to_point_id NA olacağından hoş olmaz. 

opt02: get_routes.R içinde from_point_id ve to_point_id kullanarak rotaları tanımla. Böylece girdi verimizle pmap uygulaması birbiriyle daha uyumlu hale de gelir hem.

#### opt02: get_routes.R içinde from_point_id ve to_point_id kullanarak rotaları tanımla

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex31b.R`

Test manually

``` r
source("get_routes_ex31b.R")
routes_all = get_routes_verbal()
r0 = get_routes_by_smi_wkd(routes_all, 7, 0)
get_route_upto_sequence_no(r0, 1)
  ##>   salesman_id week_day from_point_id to_point_id from_lat from_lng to_lat to_lng sequence_no
  ##>         <dbl>    <dbl>         <dbl>       <dbl>    <dbl>    <dbl>  <dbl>  <dbl>       <dbl>
  ##> 1           7        0             1         183     40.9     29.2   41.0   29.1           0
  ##> 2           7        0           183         595     41.0     29.1   41.0   29.0           1
  ##> 2           7        0           183         595     41.0     29.1   41.0   29.0           2
``` 

`get_route_upto_sequence_no` mantığı eski mantıkta kalmış. Her bir satır artık bir rota. Fazladan satır döndürmemeli.

``` r
get_route_upto_sequence_no = function(routes, sqn) {
	routes %>%
		dplyr::filter(sequence_no <= sqn) 
}
``` 

``` r
get_route_upto_sequence_no(r0, 1)
  ##>   salesman_id week_day from_point_id to_point_id from_lat from_lng to_lat to_lng sequence_no
  ##>         <dbl>    <dbl>         <dbl>       <dbl>    <dbl>    <dbl>  <dbl>  <dbl>       <dbl>
  ##> 1           7        0             1         183     40.9     29.2   41.0   29.1           0
  ##> 2           7        0           183         595     41.0     29.1   41.0   29.0           1
``` 

Fakat şimdi de sequence_no 0'dan başladığı için yine iki adım geliyor. Neden öyle yapmışız?

Kaynak veri `trips_with_costs.tsv` bu şekilde.

Muhtemelen `sequence_no`yu `from_point_id` satış noktasının sıra numarası olarak yorumlamışım.

``` r
get_route_upto_sequence_no = function(routes, sqn) {
	routes %>%
		dplyr::filter(sequence_no < sqn) 
}
``` 

Fakat böyle yaparsam da son adımı hiçbir zaman ekleyemeyeceğiz. `<=` olması lazım.

##### Error: Warning: Error in file: invalid 'description' argument

		105: file
		104: readLines
		102: fromJSON
		101: route [decode.R#38]
		100: get_routes_all [get_routes_ex31b.R#23]

Adım adım debug edelim.

``` r
source("get_routes_ex31b.R")
routes_all = get_routes_verbal()
r0 = get_routes_by_smi_wkd(routes_all, 7, 0)
r1 = get_route_upto_sequence_no(r0, 0)
  ##>   salesman_id week_day from_point_id to_point_id from_lat from_lng to_lat to_lng sequence_no
  ##>         <dbl>    <dbl>         <dbl>       <dbl>    <dbl>    <dbl>  <dbl>  <dbl>       <dbl>
  ##> 1           7        0             1         183     40.9     29.2   41.0   29.1           0
get_routes_all(r1)
  ##> Error in file(con, "r") : invalid 'description' argument
  ##> 6: file(con, "r")
  ##> 5: readLines(file, warn = FALSE)
  ##> 4: paste(readLines(file, warn = FALSE), collapse = "")
  ##> 3: fromJSON(file = url) at decode.R#38
  ##> 2: route(orig, dest) at get_routes_ex31b.R#23
``` 

Elle çalıştır url'yi

``` r
sqn = 1
routes = r1
orig = routes[sqn, ] %>%
	dplyr::select(lng = from_lng, lat = from_lat)
dest = routes[sqn, ] %>%
	dplyr::select(lng = to_lng, lat = to_lat)
url = glue::glue("http://{osrm_server}/route/v1/driving/{orig$lng},{orig$lat};{dest$lng},{dest$lat}?overview=full")
  ##> http://35.204.111.216:5000/route/v1/driving/29.208498,40.890795;29.05508,40.97364?overview=full
``` 

Sorun yok düzgün çalışıyor. 

O zaman, belirli bir parametrede hata meydana geliyor olmalı. print edelim url'yi.

``` r
route = function(orig, dest) {
	url = glue::glue("http://{osrm_server}/route/v1/driving/{orig$lng},{orig$lat};{dest$lng},{dest$lat}?overview=full")
	print(url)
	return(fromJSON(file=url))
}
get_routes_all(r1)
``` 

Sorun response dosyasını okurken meydana geliyor olabilir. 

``` r
rjson::fromJSON(file=url)
  ##> düzgün
``` 

Düzgün çalışıyor. Tek başına çalıştırınca. Fakat `get_routes_all` hata veriyor:

``` r
get_routes_all(r1)
  ##> Error in file(con, "r") : invalid 'description' argument
  ##> 6: file(con, "r")
  ##> 5: readLines(file, warn = FALSE)
  ##> 4: paste(readLines(file, warn = FALSE), collapse = "")
  ##> 3: rjson::fromJSON(file = url) at decode.R#38
  ##> 2: route(orig, dest) at get_routes_ex31b.R#23
  ##> 1: get_routes_all(r1)
``` 

Muhtemelen implicit bir variable olabilir.

Print edilen url'yi direk gönder:

``` r
url = "http://35.204.111.216:5000/route/v1/driving/29.208498,40.890795;29.05508,40.97364?overview=full"
rjson::fromJSON(file=url)
rjson::fromJSON(file= "http://35.204.111.216:5000/route/v1/driving/29.208498,40.890795;29.05508,40.97364?overview=full")
``` 

Yine düzgün çalışıyor.

opt01: Önceki örnekler çalışıyor mu?

``` r
  ##> http://35.204.111.216:5000/route/v1/driving/29.208498,40.890795;29.05508,40.97364?overview=full
	##> http://35.204.111.216:5000/route/v1/driving/29.208498,40.890795;29.05508,40.97364?overview=full
``` 

url'ler tıpatıp aynı. 

O zaman import ettiğimiz kütüphaneler bir şeyleri yanlışlıkla eziyor olabilir.

opt02: hard code et url'yi.

``` r
route = function(orig, dest) {
	url = glue::glue("http://{osrm_server}/route/v1/driving/{orig$lng},{orig$lat};{dest$lng},{dest$lat}?overview=full")
	url = "http://35.204.111.216:5000/route/v1/driving/29.208498,40.890795;29.05508,40.97364?overview=full"
	print(url)
	return(rjson::fromJSON(file=url))
}
``` 

``` r
get_routes_all(r1)
``` 

Şimdi çalıştı. Bu ne anlama geliyor?

``` r
route = function(orig, dest) {
	url = glue::glue("http://{osrm_server}/route/v1/driving/{orig$lng},{orig$lat};{dest$lng},{dest$lat}?overview=full")
	#url = "http://35.204.111.216:5000/route/v1/driving/29.208498,40.890795;29.05508,40.97364?overview=full"
	print(url)
  ##> http://35.204.111.216:5000/route/v1/driving/29.208498,40.890795;29.05508,40.97364?overview=full
	return(rjson::fromJSON(file=url))
}
``` 

``` r
get_routes_all(r1)
``` 

Şimdi hata veriyor. 

Kendi çıktısıyla hard code et

``` r
route = function(orig, dest) {
	url = glue::glue("http://{osrm_server}/route/v1/driving/{orig$lng},{orig$lat};{dest$lng},{dest$lat}?overview=full")
  url = "http://35.204.111.216:5000/route/v1/driving/29.208498,40.890795;29.05508,40.97364?overview=full"
	print(url)
	return(rjson::fromJSON(file=url))
}
``` 

Yine çalıştı.

opt03: sprintf kullan

``` r
route = function(orig, dest) {
	url = sprintf("http://%s/route/v1/driving/%s,%s;%s,%s?overview=full", osrm_server, orig$lng, orig$lat, dest$lng, dest$lat)
	print(url)
	return(rjson::fromJSON(file=url))
}
``` 

Hata veriyor.

opt04: route fonksiyonuyla debug et

``` r
r1
routes = r1
sqn = 1
orig = routes[sqn, ] %>%
	dplyr::select(lng = from_lng, lat = from_lat)
dest = routes[sqn, ] %>%
	dplyr::select(lng = to_lng, lat = to_lat)
rt = route(orig, dest)
``` 

Çalışıyor. 

Bu ne anlama geliyor?

opt05: Sistematik eleme yöntemiyle get_routes_all fonksiyonunu inceleyelim.

``` r
f1 = function(routes) {
	no_routes = nrow(routes) - 1
	pal <- colorNumeric(c('#2e86c1' , '#5dade2' , '#8e44ad' , '#9b59b6' , '#a93226' , '#ec7063'), 1:6)
	col = rep(pal(1:6), times = 1 + (no_routes / 6))

	m <- leaflet(width="100%") %>% 
		addTiles()  

	for (sqn in 1:no_routes) {
		orig = routes[sqn, ] %>%
			dplyr::select(lng = from_lng, lat = from_lat)
		dest = routes[sqn, ] %>%
			dplyr::select(lng = to_lng, lat = to_lat)
		rt = route(orig, dest)
		ph = path(rt)
		m = m %>% 
			addPolylines(data = ph, label = route_label(rt), color = col[sqn], opacity=1, weight = 3) %>%
			addMarkers(lng=orig$lng, lat=orig$lat, popup=glue("Market {sqn-1}"), label = glue("{sqn-1}")) %>%
			addMarkers(lng=dest$lng, lat=dest$lat, popup=glue("Market {sqn}"), label = glue("{sqn}")) 
	}
	return(m)
}
f1(r1)
  ##> hata
``` 

``` r
f2 = function(routes) {
	sqn = 1
	orig = routes[sqn, ] %>%
		dplyr::select(lng = from_lng, lat = from_lat)
	dest = routes[sqn, ] %>%
		dplyr::select(lng = to_lng, lat = to_lat)
	rt = route(orig, dest)
}
f2(r1)
  ##> çalışıyor
``` 

``` r
f3 = function(routes) {
	no_routes = nrow(routes) - 1
	pal <- colorNumeric(c('#2e86c1' , '#5dade2' , '#8e44ad' , '#9b59b6' , '#a93226' , '#ec7063'), 1:6)
	col = rep(pal(1:6), times = 1 + (no_routes / 6))

	m <- leaflet(width="100%") %>% 
		addTiles()  
	sqn = 1
	orig = routes[sqn, ] %>%
		dplyr::select(lng = from_lng, lat = from_lat)
	dest = routes[sqn, ] %>%
		dplyr::select(lng = to_lng, lat = to_lat)
	rt = route(orig, dest)
}
f3(r1)
  ##> çalışıyor
``` 

``` r
f4 = function(routes) {
	no_routes = nrow(routes) - 1
	pal <- colorNumeric(c('#2e86c1' , '#5dade2' , '#8e44ad' , '#9b59b6' , '#a93226' , '#ec7063'), 1:6)
	col = rep(pal(1:6), times = 1 + (no_routes / 6))

	m <- leaflet(width="100%") %>% 
		addTiles()  
	for (sqn in 1:no_routes) {
		orig = routes[sqn, ] %>%
			dplyr::select(lng = from_lng, lat = from_lat)
		dest = routes[sqn, ] %>%
			dplyr::select(lng = to_lng, lat = to_lat)
		rt = route(orig, dest)
	}	
}
f4(r1)
  ##> hata
``` 

Demek sorun `for` satırından kaynaklanıyor

``` r
f5 = function(routes) {
	for (sqn in 1:nrow(routes) - 1 ) {
		print(sqn)
		##> 0
		orig = routes[sqn, ] %>%
			dplyr::select(lng = from_lng, lat = from_lat)
		dest = routes[sqn, ] %>%
			dplyr::select(lng = to_lng, lat = to_lat)
		rt = route(orig, dest)
	}	
}
f5(r1)
  ##> hata
``` 

`sqn = 0` olunca, orig ve dest doğal olarak empty tibble objeleri oluyor.

Peki bu durumda route() içinde nasıl url oluşturulabiliyor?

``` r
sqn = 0
routes = r1
orig = routes[sqn, ] %>%
	dplyr::select(lng = from_lng, lat = from_lat)
dest = routes[sqn, ] %>%
	dplyr::select(lng = to_lng, lat = to_lat)
rt = route(orig, dest)
``` 

Sebebi: `for (sqn in 1:0)` aslında iki tane döngü çalıştırıyor. İlkinde `sqn = 1` ikincisinde `sqn = 0`. Bizim gördüğümüz url, ilk döngü çalışmasına dair.

### Dosya path'lerini env var'dan alalım

``` r
PEYMAN_PROJECT_DIR = Sys.getenv("PEYMAN_PROJECT_DIR")
if (PEYMAN_PROJECT_DIR == "") {
	PEYMAN_PROJECT_DIR = "~"
}
``` 

localhost:

``` bash
export PEYMAN_PROJECT_DIR="$HOME/projects/itr/peyman"
``` 

server:

``` bash
export PEYMAN_PROJECT_DIR="$HOME"
``` 

### Tam ekran yapalım

Run `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex32.R`

``` r
    tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}")
``` 


