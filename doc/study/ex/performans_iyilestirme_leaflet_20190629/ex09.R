library(dplyr)
library(readr)
library(curl)
source("decode.R")

c0 = readr::read_tsv("trips_with_route_geometry.tsv") %>%
	dplyr::select(from_point_id, to_point_id, from_lng, from_lat, to_lng, to_lat, route_geometry)

p0 = decode(c0$route_geometry[1], multiplier=1e5)
str(p0)
  ##> Formal class 'SpatialLines' [package "sp"] with 3 slots
  ##>   ..@ lines      :List of 1
  ##>   .. ..$ :Formal class 'Lines' [package "sp"] with 2 slots
  ##>   .. .. .. ..@ Lines:List of 1
  ##>   .. .. .. .. ..$ :Formal class 'Line' [package "sp"] with 1 slot
  ##>   .. .. .. .. .. .. ..@ coords: num [1:377, 1:2] 29.2 29.2 29.2 29.2 29.2 ...
  ##>   .. .. .. .. .. .. .. ..- attr(*, "dimnames")=List of 2
  ##>   .. .. .. .. .. .. .. .. ..$ : chr [1:377] "1" "2" "3" "4" ...
  ##>   .. .. .. .. .. .. .. .. ..$ : chr [1:2] "lng" "lat"
  ##>   .. .. .. ..@ ID   : chr "1"
  ##>   ..@ bbox       : num [1:2, 1:2] 29.1 40.9 29.2 41
  ##>   .. ..- attr(*, "dimnames")=List of 2
  ##>   .. .. ..$ : chr [1:2] "x" "y"
  ##>   .. .. ..$ : chr [1:2] "min" "max"
  ##>   ..@ proj4string:Formal class 'CRS' [package "sp"] with 1 slot
  ##>   .. .. ..@ projargs: chr "+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"


c4 = c0 %>%
	dplyr::mutate(path = decode(route_geometry, multiplier=1e5))
	
