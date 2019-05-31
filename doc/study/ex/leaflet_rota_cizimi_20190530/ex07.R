library(sp)
library(rgeos)

## from the sp vignette:
c1 <- cbind(c(1, 2, 3), c(3, 2, 2))
  ##>      [,1] [,2]
  ##> [1,]    1    3
  ##> [2,]    2    2
  ##> [3,]    3    2
c2 <- cbind(c(1, 2, 3), c(1, 1.5, 1))
  ##>      [,1] [,2]
  ##> [1,]    1  1.0
  ##> [2,]    2  1.5
  ##> [3,]    3  1.0

ln1 <- Line(c1)
  ##> An object of class "Line"
  ##> Slot "coords":
  ##>      [,1] [,2]
  ##> [1,]    1    3
  ##> [2,]    2    2
  ##> [3,]    3    2
ln2 <- Line(c2)

s1 <- Lines(list(ln1), ID = "a")
s2 <- Lines(list(ln2), ID = "b")

sln <- SpatialLines(list(s1, s2))

rgeos::gLength(sln[1,])
  ##> [1] 2.414214

df <- data.frame(len = sapply(1:length(sln), function(i) rgeos::gLength(sln[i, ])))
  ##>        len
  ##> 1 2.414214
  ##> 2 2.236068

rownames(df) <- sapply(1:length(sln), function(i) sln@lines[[i]]@ID)
  ##>        len
  ##> a 2.414214
  ##> b 2.236068


## SpatialLines to SpatialLinesDataFrame
sldf <- SpatialLinesDataFrame(sln, data = df)

plot(sldf, col = c("red", "blue"))
text(labels = paste0("length = ", round(sldf@data$len, 2)), 
     x = rgeos::gCentroid(sldf, byid = TRUE)$x,
     y = rgeos::gCentroid(sldf, byid = TRUE)$y)

