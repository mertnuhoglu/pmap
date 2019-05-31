library("leaflet")
library("rjson")
library("bitops")
library("sp")
source("decode.R")

osrm_server = Sys.getenv("OSRM_SERVER")

ps = "
lng,lat
29.208498,40.890795
29.24633,40.9894
29.08812,40.99462
29.233,40.87585
"
cs <- read.csv(text=ps, header = T)

o = cs[1,]
d = cs[2,]
url = glue::glue("http://{osrm_server}/route/v1/driving/{o$lng},{o$lat};{d$lng},{d$lat}?overview=full")
route <- fromJSON(file=url)

path <- decode(route$routes[[1]]$geometry, multiplier=1e5)

route_label = function(route) {
	s <- route$routes[[1]]$duration
	kms <- round(route$routes[[1]]$distance/1000, 1)
	result = glue::glue("{s%/%60}m {round(s%%60, 0)}s {kms}km")
	return(result)
}

m <- leaflet(width="100%") %>% 
  addTiles()  %>% 
  addPolylines(data = path, popup = route_label(route), color = "#AC0505", opacity=1, weight = 3) %>%
  addMarkers(lng=o$lng, lat=o$lat, popup="Depo") %>%
  addMarkers(lng=d$lng, lat=d$lat, popup="Market 01")
m
