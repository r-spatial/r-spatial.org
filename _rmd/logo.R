png("logo.png", 150, 50)
layout(matrix(1:3,1,3))
par(mar=rep(0, 4))
n = 10
#set.seed(13331)
set.seed(13531)
library(deldir)
x = runif(n); y = runif(n)

library(gstat)
library(sp)
r = 50; c = 50
#m = matrix(rnorm(r*c), r, c)
#image(m, col = bpy.colors())

gr = expand.grid(x = 1:r, y = 1:c)
gridded(gr) = ~x+y
v = vgm(.55, "Sph", 100)
g = gstat(NULL, "var1", lzn~1, beta = 5.9, nmax = 20, model = v, dummy = TRUE)
out = predict(g, gr, nsim = 20)

nc <- rgdal::readOGR(system.file("shapes/", package="maptools"), "sids")

box = cbind(c(-77.75,-77.25,-77.25,-77.75,-77.75),c(35.25,35.25,35.75,35.75,35.25))
# box[,1] = box[,1] - 0.25
p = SpatialPolygons(list(Polygons(list(Polygon(box)), "ID1")))

library(rgeos)
library(RColorBrewer)

g = gIntersection(nc, p, byid = TRUE)

plot(deldir(x, y), pch = 16, wlines = "tess", lty=1, xaxs = "i", yaxs = "i")
box()
plot(g, col = brewer.pal(6, "Set2"), xaxs = "i", yaxs = "i")
image(out[1], col = bpy.colors(), xaxs = "i", yaxs = "i")

dev.off()
