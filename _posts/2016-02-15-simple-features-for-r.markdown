---
layout: post
title:  "Simple features for R"
date:   2016-02-15 10:00:00 +0100
comments: true
categories: r
---

Simple features are a standard for the exchange of spatial feature
data, meaning points, lines and polygons (and not e.g. vector
topology, networks, or rasters). Simple features have well-known text
(WKT) and a well-known binary (WKB) representations, the [wikipedia
page on WKT](https://en.wikipedia.org/wiki/Well-known_text) is
sweet and short and should be read first if you are new to simple
features. A few examples are (taken from wikipedia):

Type        |Example (WKT)
------------|---------------------------------------------
`Point`     |`POINT (30 10)`
`LineString`|`LINESTRING (30 10, 10 30, 40 40)`
`Polygon`   |`POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))`
            |`POLYGON ((35 10, 45 45, 15 40, 10 20, 35 10),`
            |`(20 30, 35 35, 30 20, 20 30))`

Today, simple features are everywhere where spatial data is
moved across systems. For instance, [PostGIS](http://www.postgis.net/)
uses it to store geometry in spatial tables, the
[geoJSON](https://datatracker.ietf.org/doc/draft-ietf-geojson/?include_text=1)
draft standard is based on it, the data model of the ubiquitous
[GDAL/OGR](http://www.gdal.org/) library is based on it.

The way R handles feature data (notably by the
[sp](https://cran.r-project.org/package=sp) package and it's
dependencies) predates the simple feature standard, and is inspired
by the practice of the time it was written, when `standard' meant
being able to read and write shapefiles.  The current mapping
between simple feature types and classes in sp are:

Simple Feature type            | sp class                | dimension
-------------------------------|-------------------------|----------
`Point`                        | `SpatialPoints`         | `XY`, `XYZ`
`MultiPoint`                   | `SpatialMultiPoints`    | `XY`, `XYZ`
`LineString`, `MultiLineString`| `SpatialLines`          | `XY`
`Polygon`, `MultiPolygon`      | `SpatialPolygons`       | `XY`


Although this ``still works'' for many practical cases, it means that

* certain classes, such as `LineString` and `Polygon` can be read into R, but would written back as a different type (as `MultiLineString` or `MultiPolygon`)
* many simple feature types (`GeometryCollection`, `CircularString`, `CompoundCurve`, `CurvePolygon`, `MultiCurve`, `MultiSurface`, `Curve`, `Surface`, `PolyhedralSurface`, `TIN`, `Triangle`) have no equivalence in R (or have one, but lack an interface)
* most three-dimensional geometries (`XYZ`) and all geometries with coordinate-attributes (`XYM`) cannot be read in or written from R.

We developed an [ISC proposal](https://www.r-consortium.org/about/isc/proposals) to
bring simple features to R. The proposal can be read [here](https://github.com/edzer/sfr).
