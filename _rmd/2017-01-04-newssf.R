## ------------------------------------------------------------------------
library(sf)

## ------------------------------------------------------------------------
t = try(st_crs("+proj=longlat +datum=NAD26"))
attr(t, "condition")

## ----fig=TRUE, fig.path = "images/", label="plot-sfnews1", fig.width=14, fig.height=12----
nc = st_read(system.file("gpkg/nc.gpkg", package="sf"), quiet = TRUE)
plot(nc)

## ----fig=TRUE, fig.path = "images/", label="plot-sfnews2"----------------
plot(nc["SID79"])

## ----fig=TRUE, fig.path = "images/", label="plot-sfnews3"----------------
plot(st_geometry(nc))

## ----fig=TRUE, fig.path = "images/", label="plot-sfnews4"----------------
nc_sp = st_transform(nc["SID79"], 32119) # NC state plane, m
plot(nc_sp, graticule = st_crs(nc), axes = TRUE)

## ----fig=TRUE, echo=FALSE, fig.path = "images/", label="plot-sfnews5"----
library(sp)
library(maps)

m = map('usa', plot = FALSE, fill = TRUE)
ID0 <- sapply(strsplit(m$names, ":"), function(x) x[1])

library(maptools)
m <- map2SpatialPolygons(m, IDs=ID0, proj4string = CRS("+init=epsg:4326"))

library(sf)

laea = st_crs("+proj=laea +lat_0=30 +lon_0=-95") # Lambert equal area
m <- st_transform(st_as_sf(m), laea)

bb = st_bbox(m)
bbox = st_linestring(rbind(c( bb[1],bb[2]),c( bb[3],bb[2]),
   c( bb[3],bb[4]),c( bb[1],bb[4]),c( bb[1],bb[2])))

g = st_graticule(m)
plot(m, xlim = 1.2 * c(-2450853.4, 2186391.9))
plot(g[1], add = TRUE, col = 'grey')
plot(bbox, add = TRUE)
points(g$x_start, g$y_start, col = 'red')
points(g$x_end, g$y_end, col = 'blue')

invisible(lapply(seq_len(nrow(g)), function(i) {
if (g$type[i] == "N" && g$x_start[i] - min(g$x_start) < 1000)
	text(g[i,"x_start"], g[i,"y_start"], labels = parse(text = g[i,"degree_label"]), 
		srt = g$angle_start[i], pos = 2, cex = .7)
if (g$type[i] == "E" && g$y_start[i] - min(g$y_start) < 1000)
	text(g[i,"x_start"], g[i,"y_start"], labels = parse(text = g[i,"degree_label"]), 
		srt = g$angle_start[i] - 90, pos = 1, cex = .7)
if (g$type[i] == "N" && g$x_end[i] - max(g$x_end) > -1000)
	text(g[i,"x_end"], g[i,"y_end"], labels = parse(text = g[i,"degree_label"]), 
		srt = g$angle_end[i], pos = 4, cex = .7)
if (g$type[i] == "E" && g$y_end[i] - max(g$y_end) > -1000)
	text(g[i,"x_end"], g[i,"y_end"], labels = parse(text = g[i,"degree_label"]), 
		srt = g$angle_end[i] - 90, pos = 3, cex = .7)
}))

## ----fig=TRUE, fig.path = "images/", label="plot-sfnews6"----------------
caree = st_crs("+proj=eqc")
plot(st_transform(nc[1], caree), graticule = st_crs(nc), axes=TRUE, lon = -84:-76)

## ----fig=TRUE, fig.path = "images/", label="plot-sfnews8"----------------
plot(nc[1], graticule = st_crs(nc), axes = TRUE)

## ----fig=TRUE, fig.path = "images/", label="plot-sfnews7"----------------
mean(st_bbox(nc)[c(2,4)])
eqc = st_crs("+proj=eqc +lat_ts=35.24")
plot(st_transform(nc[1], eqc), graticule = st_crs(nc), axes=TRUE)

## ------------------------------------------------------------------------
centr = st_centroid(nc)
st_distance(centr[c(1,10)])[1,2]
centr.sp = st_transform(centr, 32119) # NC state plane, m
st_distance(centr.sp[c(1,10)])[1,2]
centr.ft = st_transform(centr,  2264) # NC state plane, US feet
st_distance(centr.ft[c(1,10)])[1,2]

## ------------------------------------------------------------------------
st_distance(centr[c(1,10)])[1,2]                     # NAD27
st_distance(st_transform(centr, 4326)[c(1,10)])[1,2] # WGS84

## ------------------------------------------------------------------------
library(sp)
st_area(nc[1:10,])

