png("logo.png", 200, 50)
layout(matrix(1:4,1,4))
par(mar=rep(0, 4))

# 1:
n = 10
#set.seed(13331)
set.seed(13531)
library(deldir)
x = runif(n); y = runif(n)
plot(deldir(x, y), col = grey(.5), pch = 16, wlines = "tess", lty=1, xaxs = "i", yaxs = "i")
points(x,y, pch = 16)
box()

# 2:
nc <- rgdal::readOGR(system.file("shapes/", package="maptools"), "sids")
box = cbind(c(-77.75,-77.25,-77.25,-77.75,-77.75),c(35.25,35.25,35.75,35.75,35.25))
library(sp)
p = SpatialPolygons(list(Polygons(list(Polygon(box)), "ID1")))
library(rgeos)
library(RColorBrewer)
g = gIntersection(nc, p, byid = TRUE)
plot(g, col = brewer.pal(6, "Set2"), xaxs = "i", yaxs = "i")

# 3:
library(gstat)
r = 50; c = 50
gr = expand.grid(x = 1:r, y = 1:c)
gridded(gr) = ~x+y
v = vgm(.55, "Sph", 100)
g = gstat(NULL, "var1", lzn~1, beta = 5.9, nmax = 20, model = v, dummy = TRUE)
out = predict(g, gr, nsim = 20)
image(out[1], col = bpy.colors(), xaxs = "i", yaxs = "i")
box()

# 4:
library(MASS)
k = kde2d(x, y)
contour(k, nlevels = 5, drawlabels=FALSE, xaxs = "i", yaxs = "i")
box()

dev.off()
