library("leaflet")

# Call the color function (colorNumeric) to create a new palette function
pal <- colorNumeric(c("red", "green", "blue"), 1:10)
# Pass the palette function a data vector to get the corresponding colors
pal(c(1,6,9))
  ##> [1] "#FF0000" "#52E74B" "#6754D8"
pal(1:10)
  ##>  [1] "#FF0000" "#EB7000" "#D0A100" "#AAC900" "#6AEE00" "#52E74B" "#77B785" "#7C87B0" "#6754D8" "#0000FF"
