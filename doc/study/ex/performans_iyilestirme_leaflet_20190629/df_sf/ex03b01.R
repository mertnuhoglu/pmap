# Follow https://gis.stackexchange.com/questions/222978/lon-lat-to-simple-features-sfg-and-sfc-in-r
library(data.table)
library(sf)
# your data (removed crs column)
DT <- data.table(
                 place=c("Finland", "Canada", "Tanzania", "Bolivia", "France"),
                 longitude=c(27.472918, -90.476303, 34.679950, -65.691146, 4.533465),
                 latitude=c(63.293001, 54.239631, -2.855123, -13.795272, 48.603949))
DT_sf = st_as_sf(DT, coords = c("longitude", "latitude"), 
                 crs = 4326, agr = "constant")
plot(DT_sf)

