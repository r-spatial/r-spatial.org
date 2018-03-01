---
author: Iñaki Ucar
categories: r
comments: True
date: 01 marzo, 2018
layout: post
meta-json: {"layout":"post","categories":"r","date":"01 marzo, 2018","author":"Iñaki Ucar","comments":true,"title":"Quantities for R -- First working prototype"}
title: Quantities for R -- First working prototype
---

<script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>
* TOC 
{:toc}

\[[view raw
Rmd](https://raw.githubusercontent.com//r-spatial/r-spatial.org/gh-pages/_rmd/2018-03-02-quantities-first-prototype.Rmd)\]

One week ago, the R Consortium ISC
[announced](https://www.r-consortium.org/announcement/2018/02/22/announcing-second-round-isc-funded-projects-2017)
the second round of [ISC Funded
Projects](https://www.r-consortium.org/projects/awarded-projects) under
the 2017 edition (and [the opening of the Spring 2018
call](https://www.r-consortium.org/announcement/2018/01/31/r-consortium-call-proposals-february-2018)).
As you may know, this program provides financial support for projects
that enhance the infrastructure of the R ecosystem or which benefit
large segments of the R Community. This second round includes
*Refactoring and updating the SWIG R module*, proposed by Richard Beare;
*Future Minimal API: Specification with Backend Conformance Test Suite*,
proposed by Henrik Bengtsson; *An Earth data processing backend for
testing and evaluating stars*, proposed by Edzer Pebesma, and our
*Quantities for R*,
[proposed](https://github.com/r-quantities/proposal), with the generous
assistance of Edzer Pebesma.

Quantity Calculus for R vectors
-------------------------------

As we stated in our project presentation,

> The [`units`](https://cran.r-project.org/package=units) package has
> become the reference for quantity calculus in R, with a wide and
> welcoming response from the R Community. Along the same lines, the
> [`errors`](https://cran.r-project.org/package=errors) package
> integrates and automatises uncertainty propagation and representation
> for R vectors. A significant fraction of R users, both practitioners
> and researchers, use R to analyse measurements, and would benefit from
> a joint processing of quantity values with errors.
>
> This project not only aims at orchestrating units and errors in a new
> data type, but will also extend the existing frameworks (compatibility
> with base R as well as other frameworks such as the tidyverse) and
> standardise how to import/export data with units and errors.

Our long-term goal is to build a robust architecture following the
principles established by David Flater in his [*Architecture for
Software-Assisted Quantity
Calculus*](https://doi.org/10.6028/NIST.TN.1943). As this technical note
states, there are many software libraries and packages that implement
"quantities with units" in many languages, but they differ in how they
address several issues and uncertainty (if they deal with it at all).
Regarding the latter, there are few but notable examples, such as the
[Wolfram's closed-source units
framework](http://reference.wolfram.com/language/tutorial/UnitsOverview.html),
and the C++ `measurement` class included in
[Boost.Units](http://www.boost.org/doc/libs/1_65_0/doc/html/boost_units.html).
Building on the existing `units` and `errors` packages, the new
`quantities` package will provide a unified framework to consistently
work with units and errors in R.

First steps
-----------

To this end, the [r-quantities](https://github.com/r-quantities/)
organisation on GitHub serves as a hub for all the related packages,
such as the existing CRAN packages
[`units`](https://github.com/r-quantities/units),
[`errors`](https://github.com/r-quantities/errors) and
[`constants`](https://github.com/r-quantities/constants), as well as the
new [`quantities`](https://github.com/r-quantities/quantities). This
division becomes an advantage, because it enables separate development
and maintenance of each distinct feature. But at the same time, these
packages required many changes to play nicely together. The integration
stage required [14 PR on
`units`](https://github.com/r-quantities/units/pulls?q=is%3Apr+is%3Aclosed+author%3AEnchufa2+)
that Edzer carefully revised and merged, as well as some changes on
`errors`. Nonetheless, we still have to learn all the cornerstones that
must be preserved to further enhance them in the future without breaking
the work done.

This process has led us to some interesting challenges. The first one
had to do with S3 method dispatching of generics that accept a variable
number of arguments through dots. More especifically, it was about the
concatenation method `c(...)`, and the issue arises when you need to
modify some arguments (i.e., convert units) and forward the dispatch to
the next method in the stack (errors). This problem is fully explained
in [this repository](https://github.com/Enchufa2/dispatchS3dots),
examples included, and apparently this is not possible in general.
Fortunately, we found a workaround (included in the repo) that
reinitialises the dispatch stack by calling the generic again if any
argument was modified, and finally calls `NextMethod` cleanly.

The other challenge had to do with `rbind` and `cbind`. These are S3
generics, but they are special *in a way*: as the documentation states,
**method dispatching is *not* done via `UseMethod`**, but by C-internal
dispatching. This fact poses a serious obstacle if you need to rely on
other S3 method. The final solution required to retrieve it using
`getS3method` and a local assignment to override the generic
([here](https://github.com/r-quantities/quantities/blob/master/R/misc.R#L171),
for those interested) and forward the dispatch.

First working prototype
-----------------------

A first working prototype of `quantities` can be found [on
GitHub](https://github.com/r-quantities/quantities). To test it, also
development versions of `units` and `errors` are required. They can be
installed using `devtools` or the `remotes` package:

    remotes::install_github(paste("r-quantities", c("units", "errors", "quantities"), sep="/"))

There are three main functions: `quantities<-` and `set_quantities`, to
set and convert measurement units and errors on R vectors, arrays and
matrices, and `quantities`, to retrieve them.

    library(quantities)

    ## Loading required package: units

    ## Loading required package: errors

    set.seed(1234)

    # time
    t_e <- rnorm(10, 0, 0.01)
    t_x <- 1:10 + t_e
    quantities(t_x) <- list("s", 0.01)
    t_x

    ## Units: s
    ## Errors: 0.01 0.01 0.01 0.01 0.01 ...
    ##  [1] 0.9879293 2.0027743 3.0108444 3.9765430 5.0042912 6.0050606 6.9942526
    ##  [8] 7.9945337 8.9943555 9.9910996

    # position
    xb <- (1:10)^3
    x <- set_quantities(xb + abs(rnorm(10, 0, xb * 0.01)) * sign(t_e), m, xb * 0.01)
    x

    ## Units: m
    ## Errors: 0.01 0.08 0.27 0.64 1.25 ...
    ##  [1]   0.9952281   8.0798709  27.2095886  63.9587464 126.1993676
    ##  [6] 216.2382167 341.2472374 507.3346795 722.8970185 975.8416482

From this point on, you can operate normally with these vectors as if
they were plain numeric vectors.

    # non-sensical operation
    x + t_x

    ## Error: cannot convert s into m

    # speed
    t_v <- (t_x[-1] - diff(t_x) / set_quantities(2))
    v <- diff(x) / diff(t_x)
    v

    ## Units: m/s
    ## Errors: 0.1255988 0.3858872 0.9099201 1.6004630 2.7990976 ...
    ## [1]   6.98101  18.97657  38.05448  60.56018  89.96963 126.37488 166.04077
    ## [8] 215.60076 253.77087

    # acceleration
    t_a <- t_x[-c(1, length(t_x))]
    a <- diff(v) / diff(t_v)
    a

    ## Units: m/s^2
    ## Errors: 0.4496879 1.0574082 1.8883107 3.2173529 5.3458905 ...
    ## [1] 11.85968 19.33145 22.57969 28.99600 36.58889 39.87578 49.55744 38.23576

A certain class hierarchy is set and maintained in order to ensure a
proper dispatch order. If units or errors are dropped, the object falls
back to be handled by the corresponding package. Furthermore,
compatibility methods are provided (`units<-.errors` and
`errors<-.units`) to be able to restore them seamlessly.

    class(x)

    ## [1] "quantities" "units"      "errors"

    u <- units(x)
    e <- errors(x)

    # drop units (equivalent to 'drop_units(x)')
    units(x) <- NULL
    class(x)

    ## [1] "errors"

    x

    ## Errors: 0.01 0.08 0.27 0.64 1.25 ...
    ##  [1]   0.9952281   8.0798709  27.2095886  63.9587464 126.1993676
    ##  [6] 216.2382167 341.2472374 507.3346795 722.8970185 975.8416482

    # restore them
    units(x) <- u
    class(x)

    ## [1] "quantities" "units"      "errors"

    x

    ## Units: m
    ## Errors: 0.01 0.08 0.27 0.64 1.25 ...
    ##  [1]   0.9952281   8.0798709  27.2095886  63.9587464 126.1993676
    ##  [6] 216.2382167 341.2472374 507.3346795 722.8970185 975.8416482

    # drop errors (equivalent to 'drop_errors(x)')
    errors(x) <- NULL
    class(x)

    ## [1] "units"

    x

    ## Units: m
    ##  [1]   0.9952281   8.0798709  27.2095886  63.9587464 126.1993676
    ##  [6] 216.2382167 341.2472374 507.3346795 722.8970185 975.8416482

    # restore them
    errors(x) <- e
    class(x)

    ## [1] "quantities" "units"      "errors"

    x

    ## Units: m
    ## Errors: 0.01 0.08 0.27 0.64 1.25 ...
    ##  [1]   0.9952281   8.0798709  27.2095886  63.9587464 126.1993676
    ##  [6] 216.2382167 341.2472374 507.3346795 722.8970185 975.8416482

    # drop everything (equivalent to 'quantities(x) <- NULL')
    drop_quantities(x)

    ##  [1]   0.9952281   8.0798709  27.2095886  63.9587464 126.1993676
    ##  [6] 216.2382167 341.2472374 507.3346795 722.8970185 975.8416482

There are mathematical operations that are not meaningful for certain
units. They drop units and issue a warning.

    exp(x)

    ## Warning in Math.units(x): Operation exp not meaningful for units

    ## Errors: 2.705341e-02 2.583053e+02 1.771487e+11 3.829222e+27 8.027845e+54 ...
    ##  [1]  2.705341e+00  3.228816e+03  6.561062e+11  5.983160e+27  6.422276e+54
    ##  [6]  8.148249e+93 1.591447e+148 2.151056e+220           Inf           Inf

    cos(x)

    ## Warning in Math.units(x): Operation cos not meaningful for units

    ## Errors: 0.008388831 0.077967625 0.236159688 0.577972683 0.638012419 ...
    ##  [1]  0.54431158 -0.22397314 -0.48472698  0.42946750  0.85993122
    ##  [6] -0.86195837 -0.37503495 -0.03252835  0.94581264 -0.36825300

    x2 <- x^2

    ## Warning: In 'Ops' : non-'errors' operand automatically coerced to an
    ## 'errors' object with zero error

    x2

    ## Units: m^2
    ## Errors:   0.01990456   1.29277935  14.69317782  81.86719534 315.49841893 ...
    ##  [1] 9.904789e-01 6.528431e+01 7.403617e+02 4.090721e+03 1.592628e+04
    ##  [6] 4.675897e+04 1.164497e+05 2.573885e+05 5.225801e+05 9.522669e+05

    sqrt(x)

    ## Error in Ops.units(x, 0.5): units not divisible

    sqrt(x2)

    ## Units: m
    ## Errors: 0.01 0.08 0.27 0.64 1.25 ...
    ##  [1]   0.9952281   8.0798709  27.2095886  63.9587464 126.1993676
    ##  [6] 216.2382167 341.2472374 507.3346795 722.8970185 975.8416482

Finally, measurements must be correctly expressed. Quantities are
properly formatted individually or in data frames, and units and errors
are automatically represented in base graphics.

    x

    ## Units: m
    ## Errors: 0.01 0.08 0.27 0.64 1.25 ...
    ##  [1]   0.9952281   8.0798709  27.2095886  63.9587464 126.1993676
    ##  [6] 216.2382167 341.2472374 507.3346795 722.8970185 975.8416482

    x[1]; x[2]; x[3]

    ## 1.00(1) m

    ## 8.08(8) m

    ## 27.2(3) m

    data.frame(
      t = t_a, 
      x = x[-c(1, length(x))],
      a = set_units(a, km/h/s)  # conversions propagate errors too
    )

    ##           t         x              a
    ## 1 2.00(1) s 8.08(8) m   43(2) km/h/s
    ## 2 3.01(1) s 27.2(3) m   70(4) km/h/s
    ## 3 3.98(1) s 64.0(6) m   81(7) km/h/s
    ## 4 5.00(1) s  126(1) m 100(10) km/h/s
    ## 5 6.01(1) s  216(2) m 130(20) km/h/s
    ## 6 6.99(1) s  341(3) m 140(30) km/h/s
    ## 7 7.99(1) s  507(5) m 180(40) km/h/s
    ## 8 8.99(1) s  723(7) m 140(60) km/h/s

    plot(t_a, a)
    abline(lm(drop_quantities(a) ~ drop_quantities(t_a)))

![](/images/plot-quantities-1.png)

Next steps
----------

There is plenty to do! Apart from adding documentation and tests, we
will next focus on how to import and export data with units and errors.
But to this aim, we first need to identify which are the typical formats
that can be found out there, e.g.:

-   Units and errors are provided for each value, as in the table above.
-   Errors are provided for each value, but units are included in the
    header of the table.
-   Separate columns are provided for values and errors, and units are
    included in the header of the table.
-   ...

Any input on this from the community would be very welcome. Also there
are ongoing efforts to enhance the `units` package to make it work with
user-defined units seamlessly. The current implementation is limited by
the functionality of the `udunits2` package. There are [several
branches](https://github.com/r-quantities/units/branches) exploring
different alternatives just in case `udunits2` cannot grow as `units`
will need in the future.

Acknowledgements
----------------

This project gratefully acknowledges financial support from the R
Consortium. Also I would like to thank Edzer Pebesma for his kind
support and collaboration, and of course for hosting this article.
