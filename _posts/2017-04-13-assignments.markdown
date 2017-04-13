---
author: Edzer Pebesma
biblio-style: apalike
categories: r
comments: True
date: 13 April, 2017
layout: post
link-citations: True
meta-json: {"layout":"post","link-citations":true,"categories":"r","date":"13 April, 2017","author":"Edzer Pebesma","comments":true,"title":"Reproducible assignments with R-markdown"}
title: Reproducible assignments with R-markdown
---

### Introduction

I tweeted earlier Today about 

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Evaluating 22 assignments of my MSc course that students handed in as html, and Rmd + raw data. I can reproduce each of them!</p>&mdash; Edzer Pebesma (@edzerpebesma) <a href="https://twitter.com/edzerpebesma/status/852516808171061248">April 13, 2017</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

for my course _Analysis of Spatio-Temporal Data_ in our MSc program Geoinformatics.
Barry kindly answered:

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr"><a href="https://twitter.com/edzerpebesma">@edzerpebesma</a> It would be nice to see a write-up of how you get students to this level of competence.</p>&mdash; Barry Rowlingson (@geospacedman) <a href="https://twitter.com/geospacedman/status/852520658735071232">April 13, 2017</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Well, here you go!


### The course

The course has a a goal to get familiar with what spatio-temporal
data is, and how you can analyse it, with emphasis on using
R. Analysis methods focus on spatial statistical methods (point
patterns, geostatistics, lattice data) and analysis of movement data.
The course consists of lectures and exercise meetings; for exercise
meetings students were supposed to hand in short assignments. The
larger final assignment is individual, and is like a small, reproducible
research paper and forms the basis for the final grade.

Instead of (or: in addition to) working with pre-cooked examples
that use data from a particular package, loaded by `data(dataset)`,
I encouraged students from the beginning to look for datasets
themselves, and import them in R. This way they learn, and learn
from one another

* how datasets look like in the wild
* how they are imported in R
* the hoops they have to go through to get time or date variables right, e.g. by using `as.POSIXct` or `strptime` and
* troubles that coordinates may give, e.g. their projections or degrees-minutes-seconds notation.

as well as challenges related to applying methods:

* time series analysis does not work if you have very short time series
* periodicities are often absent in yearly data, but present in sub-yearly (daily/weekly/monthly)
* spatial correlation is hard to assess with a handful of observations
* not all point-referenced datasets are meaningful input for point pattern analysis, or for geostatistical analysis
* most point pattern software assumes Carthesian coordinates, but does not check for this

### Reproducing

I've asked students to hand in assignments as [R markdown](http://rmarkdown.rstudio.com/) files so that I can not only see what they did, but also redo what they did. I've asked them specifically to

* work in a separate directory for each assignment, using _lastname_._assignmentNumber_ as directory name
* include the R markdown file, data sets, and the output (html or pdf)
* not set paths in the R markdown files
* not use absolute paths to data files
* not use `install.packages` in their R markdown file
* zip this directory and submit it to the [moodle](https://moodle.org/) system

I've also demonstrated for the whole group how things work when I reproduce this, and showed them where things go wrong. For reproducing, I have to

* download the zip, and unzip it 
* go into the directory
* double-click the R-markdown file, so rstudio starts in the right directory
* click _Knit_ to run the R markdown file and create the output html

For the final assignment, several students ended up with data sets
larger than the maximum allowed upload size; they then gave me a
link to a download link. Several students saved the result of a
long computation to a `.RData` file, uncommented the long running
section, and loaded the `.RData` instead, to limit run-time while
writing the assignment. They warned me in case run times was long.

If anyone can think of a simpler workflow (for me, or for the
students) I'd very much like to hear it!
