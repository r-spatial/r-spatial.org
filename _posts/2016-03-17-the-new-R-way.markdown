---
author: Edzer Pebesma
categories: r
comments: True
date: 17 March, 2016
layout: post
meta-json: {"layout":"post","categories":"r","date":"17 March, 2016","author":"Edzer Pebesma","comments":true,"title":"Do long tables make my code tidier?"}
title: Do long tables make my code tidier?
---

[view raw
Rmd](https://raw.githubusercontent.com/edzer/r-spatial/gh-pages/_rmd/2016-03-17-the-new-R-way.Rmd)

<script src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>
Last August, at the [geostat summer
school](http://www.geostat-course.org) organized by [Barry
Rowlingson](http://barry.rowlingson.com/) in Lancaster, I took the
opportunity to learn about modern approaches to modelling health data in
an excellent worskhop held by [Teresa
Smith](http://www.lancaster.ac.uk/staff/smithtr/) on [Basic methods for
Areal/Spatially Aggregated Data](http://geostat-course.org/node/1287).
Slides, data and R scripts are found from [Teresa's course
page](http://www.lancaster.ac.uk/staff/smithtr/). Let's first download
the data, directly from Teresa's site:

    asUrl = "http://www.lancaster.ac.uk/staff/smithtr/exampledata.RData"
    asFile = basename(asUrl)
    if (!file.exists(asFile)) 
        download.file(asUrl, asFile, mode = "wb")
    load("exampledata.RData")

For a given disease, analyzing disease data typically starts with the
raw data, which has as

-   \\(y_{ic}\\) the number of cases in area \\(i\\) and age group
    \\(c\\), and
-   \\(n_{ic}\\) the number of people (controls) in area \\(i\\) and age
    group \\(c\\).

From this, the rate of disease in age group \\(c\\), \\(p_c\\), is
computed from the data by

\\[p_c = \frac{\sum_i y_{ic}}{\sum_i n_{ic}}\\]

This is needed to estimate the expected number of disease cases per area
\\(i\\), \\(E_i = \sum_c n_{ic} p_c\\), in order to find the
standardized incidence (or mortality) ratio \\(R_i = y_i / E_i\\), where
\\(y_i = \sum_c y_{ic}\\). \\(R_i\\) is the variable we'd like to model.

So far, I could follow it -- this looks like a pretty simple weighting
exercise. Then came Teresa's script to do all this.

### The hard way

    library(SpatialEpi)

    ## Loading required package: sp

    library(tidyr)
    library(dplyr)

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

    Y = gather(NEEexample@data[,c(1, 5:12)],  age_band, y, -pc)
    N = gather(NEEexample@data[,c(1,13:20)], age_band, N, -pc)
    Y$age_band = rep(1:8, each = length(NEEexample))
    N$age_band = rep(1:8, each = length(NEEexample))
    NEEmat = left_join(Y, N)

    ## Joining by: c("pc", "age_band")

    NEEmat$PCnum = match(NEEmat$pc, NEEexample@data$pc)
    NEEmat = NEEmat[order(NEEmat$PCnum, NEEmat$age_band),]
    NEE = aggregate(NEEmat$y, by = list(pc = NEEmat$PCnum), FUN = sum)
    NEE$E = expected(NEEmat$N, NEEmat$y, n.strata = 8)

Here, `NEEexample@data` is the attribute table (`data.frame`) for the
spatial data, which has per area (row) the ID in column one, the cases
for 8 age classes in columns 5 - 12, and the controls for 8 age classes
in columns 13 - 20. What is going on here?

-   `gather` converts the areas x age class table into a long table,
-   `rep` adds numeric codes representing the age class, and assumes we
    know that `gather` put the elements in a long table *by row*, which
    is not clear to me from its documentation
-   `left_join` then joins the two tables based on the common fields.
    (Of course, this is all very safe: we never know in which order
    records are in a table, so better use `left_join` to join tables.
    But wait: in the previous step, with `rep`, we assumed we \*did$
    know the order...) Anyway, this could also have been done using

<!-- -->

    NEEmat.cbind = cbind(Y, N = N$N)

as shown by

    NEEmat.orig = left_join(Y, N)

    ## Joining by: c("pc", "age_band")

    all.equal(NEEmat.cbind, NEEmat.orig)

    ## [1] TRUE

Next,

-   `match` is used to match the 920 records (115 areas times 8
    age classes) to the original categories; the result of course equals

<!-- -->

    all.equal(NEEmat$PCnum, rep(1:115, each = 8))

    ## [1] TRUE

Then,

-   `aggregate` is used to aggregate (`sum`) records by area, and
-   `expected` (from package SpatialEpi) is called to compute
    expected counts.

I read function `expected`, I read its documentation, I read the
function again, and didn't understand. I now do; it tries to compensate
for all the lost structure, in a fairly convoluted way.

### The easy way

I see \\(y\\) and \\(n\\) as being two matrices, which, when taken as

    Y = as.matrix(NEEexample@data[, 5:12])
    N = as.matrix(NEEexample@data[,13:20])

have areas as rows, and age classes as columns. The equation

\\[p_c = \frac{\sum_i y_{ic}}{\sum_i n_{ic}}\\]

averages over areas, and calls for the ratio of the column-wise sum
vectors of these matrices, which we get by

    Pc = apply(Y, 2, sum) / apply(N, 2, sum)

Next, \\(E_i = \sum_c n_{ic} p_c\\) is obtained by the inner product of
rows in \\(n\\) and \\(p_c\\), and save it directly to the spatial
object:

    NEEexample$E = as.vector(N %*% Pc)

where `as.vector` (or alternatively, `(N %*% Pc)[,1]`) takes care of
storing the column matrix as a vector in the data.frame.

So, *two lines of code* which, if must, can be contracted to one, and no
need for external packages. Indeed,

    all.equal(NEE$E, NEEexample$E)

    ## [1] TRUE

Finally, we can compute and plot the SIR by

    NEEexample$SIR = apply(Y, 1, sum) / NEEexample$E
    spplot(NEEexample[,"SIR"], main = "Standardised incidence rate")

![](/images/disease-1.png)<!-- -->

### Does it matter?

Of course Teresa's original approach could be written way more elegantly
and tidy using the same basic approach. She explained it was inspired by
code from people who mainly work with databases. To me, the short
two-liner solution looks more like the equations in which the problem
was expressed, and that makes it the better approach. How would the math
look like that, translated to R, leads to the long solution?

[Tidying data](https://www.jstatsoft.org/article/view/v059i10) is a
great idea, but shouldn't be confused with forcing everything into long
tables -- this would degrade R to a relational database. I'm fully with
[Jeff Leek](http://simplystatistics.org/2016/02/17/non-tidy-data/) that
many tidy data are not in long tables, and haven't even started
mentioning the analysis of
[spatial](http://cran.uni-muenster.de/web/views/Spatial.html),
[temporal](http://cran.uni-muenster.de/web/views/TimeSeries.html), or
[spatiotemporal
data](http://cran.uni-muenster.de/web/views/SpatioTemporal.html).

Operating R [the new way, using dplyr, tidyr and
friends](https://github.com/ropensci/unconf16/issues/22) is a cool idea.
Writing code that obfuscates simplicity is not.

This year the geostat summer school will be in
[Albacete](http://geostat-course.org/), hosted by Virgilio. Of the 106
applicants, 60 will be selected. I'm looking forward to meeting lots of
new people, and learning more and new cool things!
