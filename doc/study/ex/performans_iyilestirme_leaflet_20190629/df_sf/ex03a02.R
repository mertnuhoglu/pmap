# from https://cran.r-project.org/web/packages/googlePolylines/vignettes/sfencode.html
library(googlePolylines)

lon <- c(144.9709, 144.9713, 144.9715, 144.9719, 144.9728, 144.9732, 
144.973, 144.9727, 144.9731, 144.9749, 144.9742)

lat <- c(-37.8075, -37.8076, -37.8076, -37.8078, -37.8079, -37.8079, 
-37.8091, -37.8107, -37.8115, -37.8153, -37.8155)

encodeCoordinates(lon, lat)
  ##> [1] "xgweFcsysZToA?g@f@oAPsD?oApFf@|Hz@`DmAvViJf@jC"

polylines <- c(
 "ohlbDnbmhN~suq@am{tAw`qsAeyhGvkz`@fge}A",
 "ggmnDt}wmLgc`DesuQvvrLofdDorqGtzzV"
)

decode(polylines)
  ##> [[1]]
  ##> 
  ##>      lat       lon
  ##> 1 26.774 -80.18999
  ##> 2 18.466 -66.11799
  ##> 3 32.321 -64.75700
  ##> 4 26.774 -80.18999
  ##> 
  ##> [[2]]
  ##>      lat       lon
  ##> 1 28.745 -70.57899
  ##> 2 29.570 -67.51400
  ##> 3 27.339 -66.66800
  ##> 4 28.745 -70.57899

