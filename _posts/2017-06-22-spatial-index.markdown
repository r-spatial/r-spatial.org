---
author: Edzer Pebesma and Roger Bivand
categories: r
comments: True
date: Jun 22, 2017
layout: post
meta-json: {"layout":"post","categories":"r","date":"Jun 22, 2017","author":"Edzer Pebesma and Roger Bivand","comments":true,"title":"Spatial indexes coming to sf"}
title: Spatial indexes coming to sf
---

Spatial indexes give you fast results on spatial queries,
such as finding whether pairs of geometries intersect
or touch, or finding their intersection. They reduce
the time to get results from quadratic in the number of
geometries to linear in the number of geometries.  A recent
[commit](https://github.com/edzer/sfr/commit/96d82b0409254c5c6f852f4b87df8d31049e35a7)
brings spatial indexes to sf for the binary logical predicates
(`intersects`, `touches`, `crosses`, `within`, `contains`,
`contains_properly`, `overlaps`, `covers`, `covered_by`), as well
as the binary predicates that yield geometries (`intersection`,
`union`, `difference`, `sym_difference`).

The spatial join function `st_join` using a logical predicate to
join features, and `aggregate` or `summarise` using `union` to union
aggregated feature geometries, are also affected by this speedup.


Antecedents
-----------

There have been attempts to use spatial planar indices, including 
enhancement issue [sfr:76](https://github.com/edzer/sfr/issues/76). 
In rgeos, GEOS STRtrees were used in 
[rgeos/src/rgeos_poly2nb.c](https://r-forge.r-project.org/scm/viewvc.php/pkg/src/rgeos_poly2nb.c?view=markup&root=rgeos), which is mirrored in a modern Rcpp setting 
[sf/src/geos.cpp, around lines 276 and 551](https://github.com/edzer/sfr/blob/master/src/geos.cpp). 
The STRtree is constructed by building envelopes (bounding boxes) of input entities, 
which are then queried for intersection with envelopes of another set of entities 
(in rgeos, R functions `gUnarySTRtreeQuery` and `gBinarySTRtreeQuery`). The use case
was to find neighbours of all the about 90,000 US Census entities in Los Angeles, via
spdep::poly2nb(), which received an argument to enter the candidate neighbours found
by Unary querying the STRtree of entities by the same entities. 


Benchmark
---------

A simple benchmark shows the obvious: `st_intersects` without spatial
index behaves quadratic in the number of geometries (black line),
and is much faster for the case where a spatial index is created,
stronger so for larger number of polygons:

![first benchmark](/images/bm1.png)

The polygon datasets used are simple checker boards with square
polygons (showing a nice [Moiré pattern](https://xkcd.com/1814/)):

![first benchmark](/images/bm0.png)

The black small square polygons are essentially matched to the red
ones;  the number of polygons along the x axis is the number of a
single geometry set (black).

To show that the behaviour of `intersects` and `intersection`
is indeed linear in the number of polygons, we show runtimes for
both, as a function of the number of polygons (where `intersection`
was divided by 10 for scaling purposes):

![second benchmark](/images/bm2.png)

Implementation
-------------
Spatial indexes are available in the
[GEOS](https://trac.osgeo.org/geos) library used by `sf`, through the
[functions](https://geos.osgeo.org/doxygen/geos__c_8h_source.html)
starting with `STRtree`. The algorithm
implements a Sort-Tile-Recursive R-tree, according to the [JTS
documentation](https://locationtech.github.io/jts/javadoc/org/locationtech/jts/index/strtree/STRtree.html)
described in  _P. Rigaux, Michel Scholl and Agnes Voisard. Spatial
Databases With Application To GIS. Morgan Kaufmann, San Francisco,
2002_.

The [sf implementation](https://github.com/edzer/sfr/commit/96d82b0409254c5c6f852f4b87df8d31049e35a7)
(some commits to follow this one) excludes some binary operations.
`st_distance`, `st_relate`, and `st_relate_pattern`, as these all
need to go through all combinations, rather than a subset found
by checking for overlapping bounding boxes.  `st_equals_exact` and
`st_equals` are excluded because they do not have an implementation
for `prepared` geometries.  `st_disjoint` could benefit from the
search tree, but needs a dedicated own implementation.

On which argument is an index built?
================================
The R-tree is built on the first argument (`x`), and used to
match all geometries over the second argument (`y`) of binary
functions.  This could give runtime differences, but for instance
for the dataset that triggered this development in
[sfr:394](https://github.com/edzer/sfr/issues/394), we see hardly
any difference:

    library(sf)
    # Linking to GEOS 3.5.1, GDAL 2.1.3, proj.4 4.9.2, lwgeom 2.3.2 r15302
    load("test_intersection.Rdata")
    nrow(test)
    # [1] 16398
    nrow(hsg2)
    # [1] 6869
    system.time(int1 <- st_intersection(test, hsg2))
    #    user  system elapsed 
    # 105.712   0.040 105.758 
    system.time(int2 <- st_intersection(hsg2, test))
    #    user  system elapsed 
    # 107.756   0.060 107.822 
    # Warning messages:
    # 1: attribute variables are assumed to be spatially constant throughout all geometries 
    # 2: attribute variables are assumed to be spatially constant throughout all geometries 

The resulting feature sets `int1` and `int2` are identical, only
the order of the features (records) and of the attribute columns
(variables) differs. Runtime without index is more than an hour.

Is the spatial index always built?
=================================
In the current implemenation it is always built of logical predicates
when argument `prepare = TRUE`, which means by default. This made
it easier to run benchmarks, and I strongly doubt anyone ever sets
`prepare = FALSE`. This may change, to have them always built.

It would be nice to also have them on `st_relate` and
`st_relate_pattern`, e.g. for rook or queen neighborhood
selections ([sfr:234](https://github.com/edzer/sfr/issues/234)), but this
still requires some work, since two non-intersecting geometries
have a predictable but not a constant relationship.

What about `prepared` geometries?
================================
[Prepared
geometries](https://trac.osgeo.org/geos/wiki/PreparedGeometry)
in GEOS are essentially indexes over single geometries and not
over sets of geometries; they speed things up in particular when
single geometries are very complex, and only for a single geometry
to single geometry comparison. The spatial indexes are indexes over
_collections_ of geometries; they make a cheap preselection based on
bounding boxes before the expensive pairwise comparison takes place.

Script used
-----------
The followinig script was used to create the benchmark plots.

     library(sf)
     sizes = c(10, 20, 50, 100, 160, 200)
     res = matrix(NA, length(sizes), 4)
     for (i in seq_along(sizes)) {
	     g1 = st_make_grid(st_polygon(list(rbind(c(0,0),c(0,1),c(1,1),c(0,1),c(0,0)))), n = sizes[i]) * sizes[i]
	     g2 = g1 + c(.5,.5)
	     res[i, 1] = system.time(i1 <- st_intersects(g1, g2))[1]
	     res[i, 2] = system.time(i2 <- st_intersects(g1, g2, prepare = FALSE))[1]
	     res[i, 3] = system.time(i1 <- st_intersection(g1, g2))[1]
	     res[i, 4] = identical(i1, i2)
     }
     plot(sizes^2, res[,2], type = 'b', ylab = 'time [s]', xlab = '# of polygons')
     lines(sizes^2, res[,1], type = 'b', col = 'red')
     legend("topleft", lty = c(1,1), col = c(1,2), legend = c("st_intersects without index", "st_intersects with spatial index"))
     plot(sizes^2, res[,3]/10, type = 'b', ylab = 'time [s]', xlab = '# of polygons')
     lines(sizes^2, res[,1], type = 'b', col = 'red')
     legend("topleft", lty = c(1,1), col = c(1,2), legend = c("st_intersection * 0.1", "st_intersects"))

