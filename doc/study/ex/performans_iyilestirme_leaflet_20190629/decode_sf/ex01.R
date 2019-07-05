library(dplyr)
library(readr)
library(sf)
library(bitops)
library(sp)

c0 = readr::read_tsv("../trips_with_route_geometry.tsv") %>%
	dplyr::select(from_point_id, to_point_id, from_lng, from_lat, to_lng, to_lat, route_geometry)

rg = c0$route_geometry[1]
multiplier = 1e5

truck <- 0
trucks <- c()
carriage_q <- 0

for (i in 0:(nchar(rg)-1)){
	ch <- substr(rg, (i+1), (i+1))
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

sl0 = SpatialLines(list(Lines(Line(res), 1)), CRS("+init=epsg:4326"))
sf0 = st_as_sf(sl0)
  ##> Simple feature collection with 1 feature and 0 fields
  ##> geometry type:  LINESTRING
  ##> dimension:      XY
  ##> bbox:           xmin: 29.11196 ymin: 40.89088 xmax: 29.2125 ymax: 40.99405
  ##> epsg (SRID):    4326
  ##> proj4string:    +proj=longlat +datum=WGS84 +no_defs
  ##>                         geometry
  ##> 1 LINESTRING (29.20862 40.890...

