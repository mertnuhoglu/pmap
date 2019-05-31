library("leaflet")
library("rjson")
library("bitops")
library("sp")

#key = Sys.getenv("GOOGLE_API_KEY")

#use google maps API to geocode a start point...
#geoservice <- "http://maps.googleapis.com/maps/api/geocode"
#(address <- paste0(geoservice, "/json?sensor=false&",
   #"address=10+Aragon+Grove,+Kingsley+Heights,+Upper+Hutt"))
  ##> [1] "http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=10+Aragon+Grove,+Kingsley+Heights,+Upper+Hutt"
#origin <- fromJSON(file=address)

#...and an end point
#(address <- paste0(geoservice, "/json?sensor=false&",
   #"address=1+Pipitea+Street,+Wellington"))
  ##> [1] "http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=1+Pipitea+Street,+Wellington"
#destination <- fromJSON(file=address)
#o <- origin$results[[1]]$geometry$location
#d <- destination$results[[1]]$geometry$location
o = list(lat = -41.12501, lng = 175.0845)
d = list(lat = -41.2756572, lng = 174.7811653)
(url <- paste0("http://router.project-osrm.org/route/v1/driving/", 
   o$lng,",",o$lat,";",d$lng,",",d$lat,"?overview=full"))
  ##> [1] "http://router.project-osrm.org/route/v1/driving/175.0845498,-41.1250097;174.7811653,-41.2756572?overview=full"
route <- fromJSON(file=url)

route$routes[[1]]$duration
  ##> [1] 1728.5
route$routes[[1]]$distance
  ##> [1] 34267
route$routes[[1]]$geometry
  ##> [1] "hf_zFufsk`@M...

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

#make a string to nicely label the route
s <- route$routes[[1]]$duration
kms <- round(route$routes[[1]]$distance/1000, 1)
routelabel <- paste0(s%/%60, "m ", s%%60, "s , ", kms, "kms")

#create a basic map
m <- leaflet(width="100%") %>% 
  addTiles()  %>% 
  addPolylines(data=path, popup=routelabel, color = "#000000", opacity=1, weight = 3) %>%
  addMarkers(lng=o$lng, lat=o$lat, popup="Wellington St") %>%
  addMarkers(lng=d$lng, lat=d$lat, popup="Occaawal St 3")
m
