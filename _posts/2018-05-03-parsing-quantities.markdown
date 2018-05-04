---
author: Iñaki Ucar
categories: r
comments: True
date: 04 May, 2018
layout: post
meta-json: {"layout":"post","categories":"r","date":"04 May, 2018","author":"Iñaki Ucar","comments":true,"title":"Using quantities to parse data with units and errors"}
title: Using quantities to parse data with units and errors
---

<script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>
* TOC 
{:toc}

\[[view raw
Rmd](https://raw.githubusercontent.com//r-spatial/r-spatial.org/gh-pages/_rmd/2018-05-03-parsing-quantities.Rmd)\]

This is the second blog post on
[`quantities`](https://github.com/r-quantities/quantities), an
R-Consortium funded project for quantity calculus with R. It is aimed at
providing integration of the 'units' and 'errors' packages for a
complete quantity calculus system for R vectors, matrices and arrays,
with automatic propagation, conversion, derivation and simplification of
magnitudes and uncertainties. This article describes and demonstrates
recent developments to load and parse rectangular data (i.e., delimited
files, such as CSV files) with units and errors. The previous article,
which discussed a first working prototype can be found
[here](https://www.r-spatial.org/r/2018/03/01/quantities-first-prototype.html).

Reporting quantities
--------------------

The [BIPM](http://www.bipm.org/) (*Bureau International des Poids et
Mesures*) is the international *authority* on measurement units and
uncertainty. The Joint Committee for Guides in Metrology (JCGM),
dependent on the BIPM together with other international standardisation
bodies, maintains two fundamental guides in metrology: the
[VIM](http://www.bipm.org/vim) ("The International Vocabulary of
Metrology -- Basic and General Concepts and Associated Terms") and the
[GUM](https://www.bipm.org/en/publications/guides/gum.html) ("Evaluation
of Measurement Data -- Guide to the Expression of Uncertainty in
Measurement"). The latter defines four ways of reporting standard
uncertainty. For example, if we are reporting a nominal mass \\(m_S\\)
of 100 g with some uncertainty \\(u_c\\):

1.  \\(m_S\\) = 100.02147 g, \\(u_c\\) = 0.35 mg; that is, quantity an
    uncertainty are reported separatedly, and thus they may be expressed
    in different units.
2.  \\(m_S\\) = 100.02147(35) g, where the number in parentheses is the
    value of \\(u_c\\) referred to the corresponding last digits of the
    reported quantity.
3.  \\(m_S\\) = 100.02147(0.00035) g, where the number in parentheses is
    the value of \\(u_c\\) expressed in the unit of the reported
    quantity.
4.  \\(m_S\\) = (100.02147 \\(\pm\\) 0.00035), where the number
    following the symbol \\(\pm\\) is the value of \\(u_c\\) in the unit
    of the reported quantity.

The second scheme is the most compact one, and it is the default
reporting mode in the `errors` package. The fourth scheme is also
supported given that it is a very extended notation, but the GUM
discourages its use to prevent confusion with confidence intervals.

In the same lines, the BIMP also publishes the [International System of
Units](https://www.bipm.org/en/measurement-units/) (SI), which consist
of seven base units and derived units, many of them with special names
and symbols. Units are reported after the corresponding quantity using
products of powers of symbols (e.g., 1 N = 1 m kg s-2).

Parsing quantities
------------------

The problem of reading and parsing quantities with errors and units
depends on the reporting scheme used. Let us consider errors first. If
1) is used, then quantities and uncertainties are reported in separate
columns. Therefore, special parsing is not necessary, and we can simply
combine the columns:

    library(quantities)

    ## Loading required package: units

    ## Loading required package: errors

    df <- readr::read_csv(
    "  d,derr
    1.02,0.05
    2.51,0.01
    3.23,0.12")

    errors(df$d) <- df$derr
    df$derr <- NULL
    df

    ## # A tibble: 3 x 1
    ##           d
    ##   <[(err)]>
    ## 1   1.02(5)
    ## 2   1.02(5)
    ## 3   1.02(5)

Then, units can be added with `units`, or both operations may be done at
the same time with the `quantities` method. So far, so good. Problems
begin when errors are reported following 2), 3) or 4):

    df <- readr::read_csv(
    "           d
           1.02(5)
        2.51(0.01)
    3.23 +/- 0.12")

    df

    ## # A tibble: 3 x 1
    ##   d            
    ##   <chr>        
    ## 1 1.02(5)      
    ## 2 2.51(0.01)   
    ## 3 3.23 +/- 0.12

### A flexible errors parser

The first thing that came to my mind to address the problem above was
*regex*. But obviously a solution based on regular expressions would be
slow, monolithic and hard to develop and maintain. Then I took a look at
the excellent `readr` package for some inspiration. There, I became
aware of the existence of [Boost Spirit](http://boost-spirit.com/home/),
which is an amazing library for building parsers.

I gave it a try, and the resulting parser was something like the
following:

    bool r = boost::spirit::qi::phrase_parse(
      first, last,
      -char_('(') >> ( LHS_ || RHS_ ) >> -err_ >> -char_(')') >> -exp_,
      boost::spirit::ascii::space
    );

where `LHS_`, `RHS_`, `err_` and `exp_` are Spirit rules to parse the
left-hand side, right-hand side, the error and the exponent of the
quantity respectively (see the full code
[here](https://github.com/r-quantities/quantities/blob/db422d68e5836f1be56a2e61da5e19bcf9677031/src/parse.h)).
Unfortunately, this flexibility and easiness comes at a cost, and such
rules are extremely slow to instantiate. As an example, parsing a vector
of length 1 million took 25 seconds in my computer. I found it very
obscure to debug and optimise, so I decided to change my approach.

The [new
implementation](https://github.com/r-quantities/quantities/blob/224d09baab3d38b66c1b2755091ef8845e198cbf/src/parse.h),
inspired again by the [numeric
parser](https://github.com/tidyverse/readr/blob/8186639405afdbfbde5c8045f69d98b51a37acea/src/QiParsers.h#L40)
implemented in `readr`, is based on a [deterministic finite
automaton](https://en.wikipedia.org/wiki/Deterministic_finite_automaton)
(DFA), which is not only very fast, but extremely flexible. It can be
used as follows:

    parse_errors(df$d)

    ## Errors: 0.05 0.01 0.12
    ## [1] 1.02 2.51 3.23

With this implementation, parsing the same 1-million vector takes around
0.3 seconds in my machine (a x80 speedup compared to the Boost-based
parser!).

### Unit parsing

The `units` package already provides a unit parser backed by the
`udunits2` package. The recommended way of parsing units is through
`as_units`:

    as_units("m kg s-2")

    ## 1 kg*m/s^2

The errors parser reports whether the string has a trailing unit. As a
result, `parse_errors` is able to warn us if units were discarded:

    parse_errors("1.02(5) m kg s-2") # warning

    ## Warning in parse_errors("1.02(5) m kg s-2"): units present but ignored

    ## 1.02(5)

Similarly, `parse_units` will warn us if errors were discarded:

    parse_units("1.02(5) m kg s-2") # warning

    ## Warning in parse_units("1.02(5) m kg s-2"): errors present but ignored

    ## 1.02 kg*m/s^2

In this case, we should use `parse_quantities` instead:

    parse_quantities("1.02(5) m kg s-2")

    ## 1.02(5) kg*m/s^2

Summary
-------

The `quantities` package provides three new methods that parse errors
and units following the GUM's recommendations:

-   `parse_quantities`: The returned value is always a `quantities`
    object.
    -   If no errors were found, a zero error is added to all
        quantities.
    -   If no units were found, all quantities are supposed to be
        unitless.
-   `parse_errors`: The returned value is always an `errors` object.
    -   If no errors were found, a zero error is added to all
        quantities.
    -   If units were found, a warning is emitted.
-   `parse_units`: The returned value is always a `units` object.
    -   If errors were found, a warning is emitted.
    -   If no units were found, all quantities are supposed to be
        unitless.

Given a rectangular data file, such as a CSV file, it can be read with
any CSV reader (e.g., base `read.csv`, `readr`'s `read_csv` or
`data.table`'s `fread`). Then, a proper parser can be used to convert
columns as required.

Typically, a data column shares the same unit, so commonly we will find
this unit specified in the column header. Consequently, a common usage
pattern would be the following:

    set_units(parse_errors(df$d), m/s)

    ## Units: m/s
    ## Errors: 0.05 0.01 0.12
    ## [1] 1.02 2.51 3.23

In fact, we must note that `parse_units` and `parse_quantities` forces
the output to share the same unit. This means that parsing a column with
non-compatible units will fail:

    parse_quantities(c("12.34(2) m/s", "36.5(1) kg"))

    ## Error in .convert_to_first_arg(args): argument 2 has units that are not convertible to that of the first argument

But if units are different but convertible, all quantities are converted
to the first unit seen:

    parse_quantities(c("12.34(2) m/s", "36.5(1) km/h"))

    ## Units: m/s
    ## Errors: 0.02000000 0.02777778
    ## [1] 12.34000 10.13889

    parse_quantities(c("36.5(1) km/h", "12.34(2) m/s"))

    ## Units: km/h
    ## Errors: 0.100 0.072
    ## [1] 36.500 44.424

All these parsers have been deliberately implemented closely following
`readr`'s style, because it would be nice to extend it in a way that
they are automatically guessed and used behind the scenes.
Unfortunately, this would require some work on `readr` to expose part of
the C++ API, and to provide some means to register parsers and column
types. We will definitely look into that!
