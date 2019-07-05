# Follow https://cran.r-project.org/web/packages/sf/vignettes/sf1.html

library(sf)

(s1 <- rbind(c(0,3),c(0,4),c(1,5),c(2,5)))
  ##>      [,1] [,2]
  ##> [1,]    0    3
  ##> [2,]    0    4
  ##> [3,]    1    5
  ##> [4,]    2    5
(ls <- st_linestring(s1))
  ##> LINESTRING (0 3, 0 4, 1 5, 2 5)
class(ls)
  ##> [1] "XY"         "LINESTRING" "sfg"

s2 <- rbind(c(0.2,3), c(0.2,4), c(1,4.8), c(2,4.8))
s3 <- rbind(c(0,4.4), c(0.6,5))
(mls <- st_multilinestring(list(s1,s2,s3)))
  ##> MULTILINESTRING ((0 3, 0 4, 1 5, 2 5), (0.2 3, 0.2 4, 1 4.8, 2 4.8), (0 4.4, 0.6 5))
class(mls)
  ##> [1] "XY"              "MULTILINESTRING" "sfg"

(sfc01 = st_sfc(mls))
  ##> Geometry set for 1 feature
  ##> geometry type:  MULTILINESTRING
  ##> dimension:      XY
  ##> bbox:           xmin: 0 ymin: 3 xmax: 2 ymax: 5
  ##> epsg (SRID):    NA
  ##> proj4string:    NA
  ##> MULTILINESTRING ((0 3, 0 4, 1 5, 2 5), (0.2 3, ...
class(sfc01)
  ##> [1] "sfc_MULTILINESTRING" "sfc" 

d0 = tibble::tibble(id = 1)
d0$geom = sfc01
d0
  ##>      id                                                                 geom
  ##>   <dbl>                                                    <MULTILINESTRING>
  ##> 1     1 ((0 3, 0 4, 1 5, 2 5), (0.2 3, 0.2 4, 1 4.8, 2 4.8), (0 4.4, 0.6 5))
d1 = st_sf(d0)
d1
  ##> Simple feature collection with 1 feature and 1 field
  ##> geometry type:  MULTILINESTRING
  ##> dimension:      XY
  ##> bbox:           xmin: 0 ymin: 3 xmax: 2 ymax: 5
  ##> epsg (SRID):    NA
  ##> proj4string:    NA
  ##> # A tibble: 1 x 2
  ##>      id                                                                 geom
  ##>   <dbl>                                                    <MULTILINESTRING>
  ##> 1     1 ((0 3, 0 4, 1 5, 2 5), (0.2 3, 0.2 4, 1 4.8, 2 4.8), (0 4.4, 0.6 5))
class(d1)
  ##> [1] "sf"         "tbl_df"     "tbl"        "data.frame"

