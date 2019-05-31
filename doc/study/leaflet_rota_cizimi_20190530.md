
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

## Examples:

### ex05: Birden çok noktayı koyma

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

### ex06: Noktaları bir fonksiyon haline getirme

#### Error: All columns in a tibble must be 1d or 2d objects:

``` r
rs = dplyr::tibble( path = w1, route = r1)
``` 

		Error: All columns in a tibble must be 1d or 2d objects:
		* Column `path` is SpatialLines

### ex07: SpatialLines ile dataframe oluşturma

https://gis.stackexchange.com/questions/163286/how-do-i-create-a-spatiallinesdataframe-from-a-dataframe

### ex08: 2d object as a column in a tibble

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

### ex09: for loop ile leaflet addPolylines çağır

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

### ex10: color palet kullanımını test et

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex10.R`

``` r
pal <- colorNumeric(c("red", "green", "blue"), 1:10)
pal(1:10)
  ##>  [1] "#FF0000" "#EB7000" "#D0A100" "#AAC900" "#6AEE00" "#52E74B" "#77B785" "#7C87B0" "#6754D8" "#0000FF"
``` 

### ex11: renk paletini rotalarda kullan

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex11.R`

``` r
no_routes = nrow(cs) - 1
pal <- colorNumeric(c("red", "green", "blue"), 1:no_routes)
col = pal(1:no_routes)
...
		addPolylines(data = ph, popup = route_label(rt), color = col[i], opacity=1, weight = 3) %>%
``` 

### ex12: bir satıcının tüm rotalarını çizdir

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

### ex13: leaflet shiny basic app

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

### ex14: leaflet height full screen

https://stackoverflow.com/questions/36469631/how-to-get-leaflet-for-r-use-100-of-shiny-dashboard-height

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex14.R`

### ex15: Kendi rotalarımızı bu appte gösterelim

Edit `~/projects/itr/peyman/pmap/doc/study/ex/leaflet_rota_cizimi_20190530/ex15.R`


