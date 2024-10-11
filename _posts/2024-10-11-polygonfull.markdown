---
title: "Introducing: the POLYGON FULL"
author: "Edzer Pebesma"
date:  "11 October 2024"
comments: false
layout: post
categories: r
---
* TOC 
{:toc}

\[[view raw
Rmd](https://raw.githubusercontent.com//r-spatial/r-spatial.org/gh-pages/_rmd/2024-10-11-polygonfull.Rmd)\]

## Summary

This post introduces the `POLYGON FULL` geometry, new in `sf` 1.0-18
which appeared on CRAN Today.

## Why?

Polygons delineate a two-dimensional bound *area*. The OGC [simple
feature access
standard](https://portal.ogc.org/files/?artifact_id=25355) defines
besides the regular `POLYGON` and `MULTIPOLYGON` (a set of polygons)
also the `POLYGON EMPTY` and `MULTIPOLYGON EMPTY`, which can both be
thought of as “no points”. There is however nothing polygonal about “no
points”, you can read more about this in [Even Rouault’s blog
entry](https://erouault.blogspot.com/2024/09/those-concepts-in-geospatial-field-that.html).

Although the simple feature standard does not explicitly state this, it
was clearly developed [for flat, planar
geometries](https://r-spatial.org/book/04-Spherical.html). The Earth
however is round, and doing geometrical operations e.g. on the
two-dimensional surface of a sphere changes many things. One of them is
that the total, entire surface is also a bound area. To denote that
area, since `sf` 1.0-18 we can now use `POLYGON FULL`.

## How?

As [of 2020](https://r-spatial.org/r/2020/06/17/s2.html), R package `sf`
uses the R packgae `s2` and the `s2geometry` library for computations on
geometries with geodetic (unprojected) coordinates, unless it is told
not to do so (and assume a flat Earth) by

    library(sf)

    ## Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2() is TRUE

    sf_use_s2(FALSE)

    ## Spherical geometry (s2) switched off

The `s2geomety` library uses the concept of a `POLYGON FULL`, and
represents it internally by `POLYGON((0 -90, 0 -90))`. Package `sf` also
does this:

    sf_use_s2(TRUE)

    ## Spherical geometry (s2) switched on

    (p = st_as_sfc("POLYGON FULL", crs = 'OGC:CRS84'))

    ## Geometry set for 1 feature 
    ## Geometry type: POLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: -180 ymin: -90 xmax: 180 ymax: 90
    ## Geodetic CRS:  WGS 84 (CRS84)

    ## POLYGON FULL

If `s2` is switched off, this geometry is not recognized as a
`POLYGON FULL` but instead is printed as the `POLYGON((0 -90, 0 -90))`:

    sf_use_s2(FALSE)

    ## Spherical geometry (s2) switched off

    p

    ## Geometry set for 1 feature 
    ## Geometry type: POLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: -180 ymin: -90 xmax: 180 ymax: 90
    ## Geodetic CRS:  WGS 84 (CRS84)

    ## POLYGON ((0 -90, 0 -90))

which obviously is not a valid polygon

    st_is_valid(p)

    ## [1] NA

and will lead to errors when used, e.g. in

    st_make_valid(p)

    ## Error in scan(text = lst[[length(lst)]], quiet = TRUE): scan() expected 'a real', got 'IllegalArgumentException:'

    ## Error in (function (msg) : IllegalArgumentException: Invalid number of points in LinearRing found 2 - must be 0 or >= 3

When using `s2`, it works nicely:

    sf_use_s2(TRUE)

    ## Spherical geometry (s2) switched on

    st_is_full(p)

    ## [1] TRUE

    st_is_empty(p)

    ## [1] FALSE

    st_is_valid(p)

    ## [1] TRUE

    pt = st_as_sfc("POINT(7 52)", crs = 'OGC:CRS84')
    st_intersects(p, pt)

    ## Sparse geometry binary predicate list of length 1, where the predicate
    ## was `intersects'
    ##  1: 1

    st_intersection(p, pt)

    ## Geometry set for 1 feature 
    ## Geometry type: POINT
    ## Dimension:     XY
    ## Bounding box:  xmin: 7 ymin: 52 xmax: 7 ymax: 52
    ## Geodetic CRS:  WGS 84 (CRS84)

    ## POINT (7 52)

    st_distance(p, pt)

    ## Units: [m]
    ##      [,1]
    ## [1,]    0

    st_area(p) |> units::set_units(km^2) # spherical approximation

    ## 510066073 [km^2]

    st_bbox(p)

    ## xmin ymin xmax ymax 
    ## -180  -90  180   90

## Examples

A more full example is described in [this
vignette](https://r-spatial.github.io/sf/articles/sf7.html#polygons-on-s2-divide-the-sphere-in-two-parts),
yielding this figure:

    options(s2_oriented = TRUE) # don't change orientation from here on
    co = st_as_sf(s2::s2_data_countries())
    g = st_as_sfc("POLYGON FULL", crs = 'EPSG:4326')
    oc = st_difference(g, st_union(co)) # oceans
    b = st_buffer(st_as_sfc("POINT(-30 52)", crs = 'EPSG:4326'), 9800000) # visible half
    i = st_intersection(b, oc) # visible ocean
    plot(st_transform(i, "+proj=ortho +lat_0=52 +lon_0=-30"), col = 'blue')

<img src="/images/polygonfull-1.png" style="display: block; margin: auto;" />

Some more discussion leading to the current implementation is found in
this [sf issue](https://github.com/r-spatial/sf/issues/2441). Comments are welcome in
this issue!
