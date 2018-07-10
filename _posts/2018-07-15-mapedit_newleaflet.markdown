---
layout: post
title:  mapedit and leaflet.js > 1.0
date:  "July 15, 2018"
comments: true
author: Tim Appelhans and Kenton Russell
categories: r
---

TOC

[DOWNLOADHERE]

Back in September 2016, leaflet.js went `1.0` (see [Meet Leaflet 1](https://leafletjs.com/2016/09/27/leaflet-1.0-final.html)) with a massive changelog from `0.7.0` released three years earlier.  Meanwhile, the Leaflet R ecosystem had grown to be very powerful, but also extremely interwoven and quite complex with significant efforts from Joe Cheng and the RStudio team on leaflet core, Bhaskar Karambelkar on [`leaflet.extras`](https://github.com/bhaskarvk/leaflet.extras), Tim Appelhans on [`mapview`](https://github.com/r-spatial/mapview), and many other open source contributors.  Upgrading Leaflet R to leaflet.js > 1.0 would prove to be a massive undertaking.  The `mapedit` team devoted some RConsortium hours to launching the effort, but the entire effort proved well beyond the scope of this initial contribution.  Fortunately for the R geospatial community, RStudio very generously provided Barret Schloerke to complete the daunting remaining tasks.

![screenshot of Barret Schloerke commit](/images/mapedit3-1.png)
On May 10, 2018, Barret posted [Leaflet 2.0.0](https://blog.rstudio.com/2018/05/10/leaflet-2-0-0/) on the RStudio blog with not only an upgrade to leaflet.js > 1.0 but also a full upgrade to all `leaflet.extras` dependencies and very important infrastructure improvements including a test suite to more easily keep up with a quicker leaflet.js release cadence.

`mapedit` is entirely dependent on Leaflet, so we postponed activity on `mapedit` until the new Leaflet R release.  We are pleased to announce that `mapedit` is entirely compatible with the new Leaflet and even more pleased to get back to work implementing new features and tackling issues.

In this post, we will highlight the next steps for `mapedit` in order of priority:

1. feature attribute editing

2. geojson precision

3. multiline string editing

4. crosstalk integration

5. shiny async integration.

We cannot stress enough that the success of achieving these depends greatly on feedback and ideas from the geospatial community, so we highly encourage participation at [issues](https://github.com/r-spatial/mapedit/issues).

## Install/Update

As mentioned a lot has changed recently, so we recommend updating `leaflet`, `leaflet.extras`, `mapview`, and `mapedit`.  The newest `sf` is not required, but while we are at it, we should probably update it also.


```r
install.packages(c("sf", "leaflet", "leaflet.extras", "mapview", "mapedit"))
```

## Feature Attribute Editing

`mapedit` launched with three objectives:

1. drawing, editing, and deleting features,

2. selecting and querying of features and map regions,

3. editing attributes.

So far, `mapedit` has focused on 1 and 2 with only a very quick proof of concept shown in [mapedit Intro: Ediiting Attributes](https://www.r-spatial.org/r/2017/01/30/mapedit_intro.html#editing-attributes) building on top of [geojson.io](http://geojson.io) from [Tom Macwright](https://macwright.org/).

![screenshot of geojson.io integrated in shiny](/images/mapedit_attribute_edit.gif)

Rather than build on top of geojson.io, we would like to tightly integrate attribute editing into `mapedit`.  We will track progress on [this issue](https://github.com/r-spatial/mapedit/issues/13) and would love your participation.


## Geojson Precision

[Robin Lovelace](http://www.robinlovelace.net/) discovered that at leaflet zoom level > 17 we lose coordinate precision.  Of course, this is not good enough, so we will prioritize a fix as discussed in [issue](https://github.com/r-spatial/mapedit/issues/63).  Hopefully, this leaflet.js [pull request](https://github.com/Leaflet/Leaflet/pull/5444) will make this fix fairly straightforward.

## Mulitlinestring Editing

Leaflet.js and multilinestrings don't get along as [Tim Appelhans](https://github.com/tim-salabim) reported in [issue](https://github.com/r-spatial/mapedit/issues/48#issuecomment-314853140).  For complete support of `sf`, `mapedit` should work with multilinestring, so we have promoted this to [issue 62](https://github.com/r-spatial/mapedit/issues/62).

## Crosstalk Integration

Mike Treglia tweeted an interesting use case for `mapedit` with [`crosstalk`](https://rstudio.github.io/crosstalk/).

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">want to make interactive scatterplot and map (<a href="https://twitter.com/hashtag/GIS?src=hash&amp;ref_src=twsrc%5Etfw">#GIS</a>) in <a href="https://twitter.com/hashtag/rstats?src=hash&amp;ref_src=twsrc%5Etfw">#rstats</a> - ideally where hovering over point/polygon in map highlights corresponding one in scatterplot, &amp; vice-versa. Favorite examples w/ code? thinking of leaflet/plotly/crosstalk probably, but open to alternatives</p>&mdash; Mike Treglia (@MikeTreglia) <a href="https://twitter.com/MikeTreglia/status/939537085589016577?ref_src=twsrc%5Etfw">December 9, 2017</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

We welcomed the challenge and responded with this [example](https://github.com/timelyportfolio/mapedit/blob/master/experiments/select_crosstalk.R) crosstalking mapedit/leaflet with Plotly and DT.

![screenshot of geojson.io integrated in shiny](/images/mapedit3-2.gif)

While the example mostly works, there is far too high a burden on the user.  We will try to reduce this down to a couple of lines of code.  [Issue 72](https://github.com/r-spatial/mapedit/issues/72) will track our progress. `mapedit` will remain targeted toward Shiny contexts, so this effort will focus on [crosstalk with Shiny](https://rstudio.github.io/crosstalk/shiny.html).  This plumbing for crosstalk in `mapedit` should provide a foundation for things like polygon selection in leaflet without Shiny.



## Shiny async

RStudio added async support in Shiny as described in the post [Shiny 1.1.0: Scaling Shiny with async](https://blog.rstudio.com/2018/06/26/shiny-1-1-0/) and webinar [Scaling Shiny apps with async programming](https://www.rstudio.com/resources/videos/scaling-shiny-apps-with-async-programming-june-2018/).  No promises here, but async would be very nice for `mapedit`.

## Conclusion and Thanks

As we progress towards these goals, we will post on [r-spatial.org](https://r-spatial.org), and we would love your help..  `mapedit` and many of its dependency packages are funded by the [RConsortium](https://www.r-consortium.org/).  Thanks so much to all those who have contributed to this fantastic organization.  Also, thanks to all those open source contributors in the R community.
