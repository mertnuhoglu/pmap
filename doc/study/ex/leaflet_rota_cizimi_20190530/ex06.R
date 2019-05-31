library("leaflet")
library("rjson")
library("bitops")
library("sp")
source("decode.R")

route_label = function(route) {
	s <- route$routes[[1]]$duration
	kms <- round(route$routes[[1]]$distance/1000, 1)
	result = glue::glue("{s%/%60}m {round(s%%60, 0)}s {kms}km")
	return(result)
}

osrm_server = Sys.getenv("OSRM_SERVER")

ps = "
lng,lat
29.208498,40.890795
29.24633,40.9894
29.08812,40.99462
29.233,40.87585
"
cs <- read.csv(text=ps, header = T)


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

rs = dplyr::tibble( path = w1, route = r1)
m <- leaflet(width="100%") %>% 
  addTiles()  %>% 
  addPolylines(data = w1, popup = route_label(r1), color = "#AC0505", opacity=1, weight = 3) %>%
  addPolylines(data = w2, popup = route_label(r2), color = "#AC0505", opacity=1, weight = 3) %>%
  addMarkers(lng=p1$lng, lat=p1$lat, popup="Depo", label = "0") %>%
  addMarkers(lng=p2$lng, lat=p2$lat, popup="Market 01", label = "1", labelOptions = labelOptions(noHide = T, textsize = "25px", opacity = 0.5, style = list(color = "#000", weight = 2), direction = "top")) %>%
  #addMarkers(lng=p2$lng, lat=p2$lat, popup="Market 01", label = "1", labelOptions = labelOptions(noHide = T, textsize = "15px", textOnly = T)) %>%
  addMarkers(lng=p3$lng, lat=p3$lat, popup="Market 02", label = 2)
m

