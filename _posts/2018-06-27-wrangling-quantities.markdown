---
author: Iñaki Ucar
categories: r
comments: True
date: 27 June, 2018
layout: post
meta-json: {"layout":"post","categories":"r","date":"27 June, 2018","author":"Iñaki Ucar","comments":true,"title":"Data wrangling operations with quantities"}
title: Data wrangling operations with quantities
---

<script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>
* TOC 
{:toc}

\[[view raw
Rmd](https://raw.githubusercontent.com//r-spatial/r-spatial.org/gh-pages/_rmd/2018-06-27-wrangling-quantities.Rmd)\]

This is the third blog post on
[`quantities`](https://github.com/r-quantities/quantities), an
R-Consortium funded project for quantity calculus with R. It is aimed at
providing integration of the 'units' and 'errors' packages for a
complete quantity calculus system for R vectors, matrices and arrays,
with automatic propagation, conversion, derivation and simplification of
magnitudes and uncertainties. This article investigates the
compatibility of common data wrangling operations with quantities. In
previous articles, we discussed [a first working
prototype](https://www.r-spatial.org/r/2018/03/01/quantities-first-prototype.html)
and [units and errors
parsing](https://www.r-spatial.org/r/2018/05/07/parsing-quantities.html).

Compatibility with different workflows
--------------------------------------

The bulk of this work can be found in a new vignette entitled [*A Guide
to Working with
Quantities*](https://github.com/r-quantities/quantities/blob/master/vignettes/introduction.Rmd).
There, you may find a comprehensive set of examples of the main data
wrangling operations (subsetting, ordering, transformations,
aggregations, joining and pivoting) in two distincts worflows: R base
and the [*tidyverse*](https://www.tidyverse.org/). Here, we intend to
provide a brief summary.

As we have discussed in previous articles, quantities are implemented as
S3 objects with custom units and errors attributes. All the main
operators that can be applied to vectors and arrays are properly defined
so that they are forwarded to the attributes. This is important to
preserve units (one unit for the entire vector/array), but is critical
to correctly propagate errors (one error per vector/array element). If
operations are not forwarded, object corruption occurs.

### R base

Data wrangling operations on data frames map to R functions as follows:

-   Row subsetting: `[` or `subset`.
-   Row ordering: `[` with `order`.
-   Column transformation: `within` or `transform`.
-   Row aggregation: `aggregate`.
-   Column joining: `merge`.
-   (Un)pivoting: `reshape`.

R base functions make intensive use of the `[` generic. Therefore, as
expected, all the operations work correctly with units and errors
metadata. The only drawback is that aggregations by default will drop
quantities metadata. The reason is that there is a family of functions
(not only `aggregate`, but also `by` and the `apply` family) which holds
intermediate results in lists, and these are finally simplified by
calling `unlist`.

There is no workaround for this default behaviour, because it is not
possible to define methods for *lists of something*. Fortunately, all
these functions support a parameter called `simplify` (sometimes,
`SIMPLIFY`) which, if set to `FALSE`, avoids the `unlist` call and
returns the results in a list. Then, a call to `do.call(c, ...)` will
unlist quantities without losing attributes or classes.

### Tidyverse

Data wrangling operations on data frames map to tidyverse functions as
follows:

-   Row subsetting: `dplyr::filter` (and others).
-   Row ordering: `dplyr::arrange`.
-   Column transformation: `dplyr::transmute` and `dplyr::mutate`.
-   Row aggregation: `dplyr::summarise` (and others) with
    `dplyr::group_by` for observation grouping.
-   Column joining: `dplyr::*_join` family.
-   (Un)pivoting: `tidyr::gather` and `tidyr::spread`.

The tidyverse handles quantities correctly for subsetting, ordering and
transformations. It fails to do so for aggregations (grouped operations
in general), column joining and (un)pivoting. Most of these
incompatibilities are due to the same internal grouping mechanism, which
is in C and prevents the R subsetting operator from being called (which
in turn calls the subsetting operator on the errors attribute).
Interestingly, those operations still work for units alone, except for
column gathering, which drops all classes and attributes. It seems
though that there are long-term plans in `dplyr` for supporting
vectorised attributes (see
[tidyverse/dplyr\#2773](https://github.com/tidyverse/dplyr/issues/2773)
and
[tidyverse/dplyr\#3691](https://github.com/tidyverse/dplyr/issues/3691)).

### A note on `data.table`

*Currently* (v1.11.4) `data.table` does not work well with vectorised
attributes. The underlying problem is similar to `dplyr`'s issue, but
unfortunately it affects more operations, including row subsetting and
ordering. Only column transformation seems to work, and other operations
generate corrupted objects. This issue was reported on GitHub (see
[Rdatatable/data.table\#2948](https://github.com/Rdatatable/data.table/issues/2948)).

Future directions of units and errors
-------------------------------------

A couple of weeks ago, I had the pleasure of visiting Edzer Pebesma at
the Institute for Geoinformatics in Muenster, and we had a nice
R-quantities summit.

<blockquote markdown="1" class="twitter-tweet" data-lang="es">
<p markdown="1" lang="en" dir="ltr">
R-quantities summit with
<a href="https://twitter.com/Enchufa2?ref_src=twsrc%5Etfw">@Enchufa2</a>
: merging rigorous error and units propagation to enable quantity
calculus for R vectors. Thanks to
<a href="https://twitter.com/RConsortium?ref_src=twsrc%5Etfw">@RConsortium</a>
! <a href="https://t.co/1dJAnZCyIM">https://t.co/1dJAnZCyIM</a>
<a href="https://t.co/Wp6fRrn3WQ">pic.twitter.com/Wp6fRrn3WQ</a>
</p>
— Edzer Pebesma (@edzerpebesma)
<a href="https://twitter.com/edzerpebesma/status/1006922795744456704?ref_src=twsrc%5Etfw">13
de junio de 2018</a>
</blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
We had a very productive discussion on the [future
directions](https://github.com/r-quantities/proposal/blob/master/directions.md)
of the `units` and `errors` packages. These are some of the ideas on the
table:

-   As a follow-up to the [previous
    milestone](https://www.r-spatial.org/r/2018/05/07/parsing-quantities.html),
    we found interesting the idea of enhancing the `readr` package to
    allow third-party packages to provide new column types and parsers
    that would work transparently. There are other interesting use
    cases, such as reading spatial data. We registered [the
    proposal](https://github.com/tidyverse/readr/issues/865) in the
    `readr`'s repository.
-   We discussed [a recent
    proposal](https://github.com/r-quantities/units/issues/145) by Bill
    Denney (and had a most interesting chat with him) in which he
    requests support for *mixed units* in R vectors and arrays. Bill
    works with data from clinical studies and deals with a very specific
    format. I refer to the issue at hand (previous link and references
    therein) for specific examples and further discussion. Edzer already
    started to work on this, and there is a functional prototype in the
    `mixed` branch on Github.
-   As a mid-term plan, we would also like to add support for other
    propagation methods to the `errors` package. More specifically,
    instead of storing a single value and an associated error (and
    applying TSM), we plan to provide support for full samples.
    Operations would work directly on these samples, so that every kind
    of correlation would be captured.

Next steps
----------

The R-quantities project is coming to an end. The next and final
milestone will try to provide a proof-of-concept to wrap `lm` methods,
where errors are used to define weights in the linear model and units
propagate to the regression coefficient estimates and residuals. We will
also complete the documentation with the prospect of a first release of
the `quantities` package on CRAN.
