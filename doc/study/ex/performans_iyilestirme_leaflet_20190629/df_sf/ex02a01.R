points_sf <- st_as_sf(geo_data, coords = c("lon", "lat"), crs = 4326)

points_sf
points_sf$geometry
st_geometry(points_sf)

