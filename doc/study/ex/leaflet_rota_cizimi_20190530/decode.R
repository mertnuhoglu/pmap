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

route = function(orig, dest) {
	url = glue::glue("http://{osrm_server}/route/v1/driving/{orig$lng},{orig$lat};{dest$lng},{dest$lat}?overview=full")
	return(fromJSON(file=url))
}

path = function(route) {
	return(decode(route$routes[[1]]$geometry, multiplier=1e5))
}

route_label = function(route) {
	s <- route$routes[[1]]$duration
	kms <- round(route$routes[[1]]$distance/1000, 1)
	result = glue::glue("{s%/%60}m {round(s%%60, 0)}s {kms}km")
	return(result)
}

