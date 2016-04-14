---
layout: post
title:  "sp released with new gallery"
date:   2016-04-14 11:00:00 +0100
comments: true
author: Edzer Pebesma
categories: r
---
CRAN has now accepted
[sp](https://cran.r-project.org/package=sp) version 1.2-3
([NEWS](https://cran.r-project.org/web/packages/sp/news.html)).
Besides some smaller bug fixes, it comes with

* proper plot methods for `SpatialGridDataFrame` objects (see [this](http://r-spatial.org/r/2016/03/08/plotting-spatial-grids.html) blog post), and
* a new maps [gallery](https://edzer.github.io/sp/) showcasing better graticules, the use of web maps (google or OpenStreetMaps backdrop), as well as some `ggplot`-made maps and responsive `mapview` examples.

Checking all of the direct reverse dependencies, one of the
[requirements](https://cran.r-project.org/web/packages/policies.html#Submission)
for CRAN submissions, took around half a day on a single core. It gave me

    library(tools)
    summary(check_packages_in_dir(".", reverse = "all"))
    Check status summary:
                      ERROR WARN NOTE  OK
      Source packages     0    0    0   1
	  Reverse depends     6    2   46 185
    ...


Five of the six Errors were due to missing second order reverse
dependencies, the remaining revealed an issue with RandomFields,
which had made the assumption that sp has no `plot` method for
`SpatialGridDataFrame` objects; this has been resolved with its
maintainer Martin Schlather.

The new [sp gallery](https://edzer.github.io/sp/) is not part of
the sp package distribution (like a vignette) in order to keep sp's
dependencies to a minimum.  The gallery source files are found in
the [gh-pages branch](https://github.com/edzer/sp/tree/gh-pages)
on github. Additions or improvements can be directly
submitted as pull requests, or as [issues on
github](https://github.com/edzer/sp/issues).
