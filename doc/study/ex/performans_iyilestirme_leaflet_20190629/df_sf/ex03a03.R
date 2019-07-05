library(googlePolylines)
library(sf)

polylines <- c(
 "ohlbDnbmhN~suq@am{tAw`qsAeyhGvkz`@fge}A",
 "ggmnDt}wmLgc`DesuQvvrLofdDorqGtzzV"
)

p0 = decode(polylines)
st_sfc(p0)
  ##> Error in vapply(lst, class, rep(NA_character_, 3)) :
  ##>   values must be length 3,
  ##>  but FUN(X[[1]]) result is length 1

