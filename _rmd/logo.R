# R script to produce the r-spatial.org logo
png("logo.png", 250, 50)
layout(matrix(1:5,1,5))
par(mar=rep(0, 4), xaxs = "i", yaxs = "i")

# 1:
n = 10
#set.seed(13331)
set.seed(13531)
library(deldir)
x = runif(n); y = runif(n)
plot(deldir(x, y), col = grey(.5), pch = 16, wlines = "tess", lty=1)
points(x,y, pch = 16)
box()

# 2:
library(rgdal)
nc <- readOGR(system.file("shapes/", package="maptools"), "sids")
box = cbind(c(-77.75,-77.25,-77.25,-77.75,-77.75),c(35.25,35.25,35.75,35.75,35.25))
library(sp)
p = SpatialPolygons(list(Polygons(list(Polygon(box)), "ID1")))
library(rgeos)
g = gIntersection(nc, p, byid = TRUE)
library(RColorBrewer)
plot(g, col = brewer.pal(6, "Set2"))

# 3:
r = 50; c = 50
gr = expand.grid(x = 1:r, y = 1:c)
gridded(gr) = ~x+y
library(gstat)
v = vgm(.55, "Sph", 100)
g = gstat(NULL, "var1", lzn~1, beta = 5.9, nmax = 20, model = v, dummy = TRUE)
out = predict(g, gr, nsim = 1)
image(out[1], col = bpy.colors())
box()

# 4:
library(MASS)
k = kde2d(x, y)
contour(k, nlevels = 5, drawlabels=FALSE, axes = FALSE)
box()

# 5:
maps2sp = function(xlim, ylim, l.out = 100, clip = TRUE) {
    stopifnot(require(maps))
    m = map(xlim = xlim, ylim = ylim, plot = FALSE, fill = TRUE)
    p = rbind(cbind(xlim[1], seq(ylim[1],ylim[2],length.out = l.out)),
          cbind(seq(xlim[1],xlim[2],length.out = l.out),ylim[2]),
          cbind(xlim[2],seq(ylim[2],ylim[1],length.out = l.out)),
          cbind(seq(xlim[2],xlim[1],length.out = l.out),ylim[1]))
    LL = CRS("+init=epsg:4326")
    bb = SpatialPolygons(list(Polygons(list(Polygon(list(p))),"bb")), proj4string = LL)
    IDs <- sapply(strsplit(m$names, ":"), function(x) x[1])
    stopifnot(require(maptools))
    m <- map2SpatialPolygons(m, IDs=IDs, proj4string = LL)
    if (!clip)
        m
    else {
        stopifnot(require(rgeos))
        gIntersection(m, bb) # cut map slice in WGS84
    }
}
m = maps2sp(c(-130,-20), c(10,75))
sp = SpatialPoints(rbind(c(-121,9), c(-121,75), c(-19,9), c(-19,75)), CRS("+init=epsg:4326"))
laea = CRS("+proj=laea +lat_0=30 +lon_0=-40")
m.laea = spTransform(m, laea)
plot(as(m.laea, "Spatial"), expandBB = c(.0, -.2, -.1, -.1))
plot(m.laea, col = grey(.4), add = TRUE)
gl = gridlines(sp, easts = c(-120,-100,-80,-60,-40,-20), norths = c(10,20,30,40,50,60,70))
gl.laea = spTransform(gl, laea)
plot(gl.laea, add = TRUE, col = grey(.8))

library(trajectories)
data(storms)
plot(as(spTransform(storms[1][1:12], laea), "SpatialLines"), add = TRUE, 
	col = brewer.pal(12, "Paired"), lwd = 3)
box()

dev.off()
