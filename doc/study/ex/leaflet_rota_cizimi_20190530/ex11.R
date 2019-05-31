library("leaflet")
library("rjson")
library("bitops")
library("sp")
source("decode.R")
library("glue")

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

path = function(route) {
	return(decode(route$routes[[1]]$geometry, multiplier=1e5))
}

no_routes = nrow(cs) - 1
pal <- colorNumeric(c("red", "green", "blue"), 1:no_routes)
col = pal(1:no_routes)
m <- leaflet(width="100%") %>% 
  addTiles()  

for (i in 1:no_routes) {
	p1 = cs[i, ]
	p2 = cs[i+1, ]
	rt = route(p1, p2)
	ph = path(rt)
	m = m %>% 
		addPolylines(data = ph, popup = route_label(rt), color = col[i], opacity=1, weight = 3) %>%
		addMarkers(lng=p1$lng, lat=p1$lat, popup=glue("Market {i}"), label = glue("{i}")) 
}
m = m %>%
  addMarkers(lng=p2$lng, lat=p2$lat, popup=glue("Market {i+1}"), label = glue("{i+1}")) 
m

