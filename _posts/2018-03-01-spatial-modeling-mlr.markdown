---
author: Patrick Schratz
biblio-style: apalike
bibliography: ../bibs/spatial\_modeling\_`mlr`.bib
categories: r
comments: True
date: 01 March, 2018
layout: post
---
link-citations: True
title: A practical guide to performance estimation of spatially tuned
  machine-learning models for spatial data using `mlr`

<script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>
* TOC 
{:toc}

\[[view raw
Rmd](https://raw.githubusercontent.com//r-spatial/r-spatial.org/gh-pages/_rmd/2018-03-01-spatial-modeling-mlr.Rmd)\]

Introduction
============

Recently we started to integrate the spatial partitioning methods of
[sperrorest](https://mlr-org.github.io/mlr-tutorial/devel/html/handling_of_spatial_data/index.html)
into [mlr](http://mlr-org.github.io). `mlr` is a unified interface to
conduct all kind of modeling (similar to `caret`), currently supporting
more than 100 modeling packages. In comparison to sperrorest it
excelaertes by providing the option to easily tune hyperparameters. We
started with the most common spatial partitioning approach which uses
k-means clustering (see Brenning ([2012](#ref-sperrorest))). In this
blog post I will give a practical guide on how to perform a nested
spatial cross-validation in `mlr`. I will use a SVM as the algorithm
because it is a widely know and used algorithm that always needs to be
tuned to achieve good performance. Although the tuning effect of models
with meaningful default hyperparameter values such as Random Forest is
not high, one should always conduct a hyperparameter tuning as the
specific effect is not known a priori.

Everything in `mlr` is build upon the following steps: Create a task,
(tune hyperparameters), train your model, predict to a new data set.
When the model performance is to be estimated, this procedure is done
hundreds of times to reduce the variance among different traing +
predict arangements. It essentially mimics the situation that you would
apply your fitted model on 500 different unkown test data sets. You will
get a different performance on each. However, usually you have no
in-situ data to check whether your model

Creating a task
===============

The task essentially stores all information around your data set: Type
of the response variable, supervised/unsupervised, spatial or
non-spatial and many more.

I will use the example data set for spatial applications `ecuador` that
was added to `mlr`. This data set from Jannes Muenchow also comes with
sperrorest. Since the integration is quite new, we need to use the
development version of `mlr` from Github.

``` r
devtools::install_github("mlr-org/mlr")

library("mlr")
```

First, we need to create a task. Luckily, the built-in data sets of
`mlr` are already in a task structure. Check sections
[Task](https://%60mlr%60-org.github.io/%60mlr%60-tutorial/devel/html/task/index.html)
in the `mlr`-tutorial if you need to build one from scratch. To make it
a [spatial
task](https://%60mlr%60-org.github.io/%60mlr%60-tutorial/devel/html/handling_of_spatial_data/index.html),
you need to provide the coordinates of the data set in argument
`coordinates` of the task. They will later be used for the spatial
partitioning of the data set in the spatial cross-validation.

``` r
data("spatial.task")
spatial.task
#> Supervised task: ecuador
#> Type: classif
#> Target: slides
#> Observations: 751
#> Features:
#>    numerics     factors     ordered functionals 
#>          10           0           0           0 
#> Missings: FALSE
#> Has weights: FALSE
#> Has blocking: FALSE
#> Has coordinates: TRUE
#> Classes: 2
#> FALSE  TRUE 
#>   251   500 
#> Positive class: TRUE
```

We are dealing with a supervisd classication problem that has 751
observations, 10 numeric predicors, the response is “slides” and has a
distribution of 251 positive detections

Now that we have the task, we need to set up everything for the nested
spatial cross-validation. Here I’ll go for a 5 fold 100 times repeated
cross-validation in the outer level (in which the performance is
estimated) and again a five fold partitioning in the inner level (where
the hyperparameter tuning is done).

Specify the learner
===================

I prefer the SVM implementation in the `kernlab` package as it comes
with more kernel options than its competetor `e1071`.

Let’s create the learner:

``` r
learner_svm = makeLearner("classif.ksvm", predict.type = "prob")
```

The syntax is always the samke in `mlr`: The prefix always specifies the
response type, e.g. “classif” or “regr”. There are even more that you
can choose from, see ???

As we have a binary response variable in this example, we set
`predict.type = "prob"` to tell the algorithm that we want to have
probabilities as outcomes.

Set the tuning method and its space
===================================

For the tuning we need to do two things: 1. Select the tuning method 2.
Set the limits of the tuning space

There are multiple options in `mlr`, see the section on
[tuning](https://pat-s.github.io/%60mlr%60/articles/tutorial/devel/tune.html#specifying-the-optimization-algorithm)
in the `mlr`-tutorial.

Random search is usually a good choice as it outperforms grid search in
high-dimensional settings (i.e. if a lot hyperparameters have to be
optimized) and has no disadvantages in low-dimensional cases (Bergstra
and Bengio [2012](#ref-Bergstra2012)).

``` r
tuning_method = makeTuneControlRandom(maxit = 50)
```

We set a budget of 50 which means that 50 different combinations of `C`
and `sigma` are checked for each fold of the CV. Depending on your
computational power you are of course free to use more. There is no rule
of thumb because because it always depends on the size of the tuning
space but you should not use less than 50.

Next, we set the tuning limits of the hyperparameters `C` and `sigma`
that we want to optimize:

``` r
ps = makeParamSet(makeNumericParam("C", lower = -5, upper = 15,
                                   trafo = function(x) 2 ^ x),
                  makeNumericParam("sigma", lower = -15, upper = 3,
                                   trafo = function(x) 2 ^ x))
```

Similar to the tuning budget, no limits exist in which a tuning should
be concucted. We will use here the limits recommended by Hsu, Chang, and
Lin ([2003](#ref-hsu2003)). thus problems applies to all
machine-learning models. Jakob Richter is working on a valuable project
that establishes a data base showing which limits were chosen by other
users (Richter [2017](#ref-mlrhyperopt)). This can then serve as a
reference point when searching tuning limits for a new algorithm.

Set the resampling method
=========================

Now that we have chosen the tuning method and the limits of the
hyperparameter to be optimized within, we need to set the resampling
method for CV that should be used.

This needs to be done twice:

1.  For the performance estimation level (outer level)
2.  For the tuning leevel (inner level) in which the hyperparameters for
    the outer level are optimized

In both cases we want to use spatial cross-validation (`SpCV`). First,
we set it for the tuning level.

``` r
inner = makeResampleDesc("SpCV", iters = 5)
```

This setting means the following: We will use 5 folds (`iters = 5`) and,
as we specified no repetition argument, one repetition will be used.
That means in practice that every random combination of hyperparameters
is applied once on each fold (5 in total) The performance of all folds
is stored and the combination with the best mean value across all folds
will be chosen as the winner.

It will be then used on the respective fold of the performance
estimation level that we still need to specify. For this level, we again
want to use five folds but this time we repeat it 100 times to reduce
variance introduced by partitioning.

``` r
outer = makeResampleDesc("SpRepCV", folds = 5, rep = 100)
```

Next, we need to create a wrapper function that uses the learner we
specified and tells `mlr` that a tuning should be performed. This
function is then plugged in to the actual `resample()` call of `mlr`.
Luckily, `mlr` already comes with such a wrapper function:

``` r
wrapper_ksvm = makeTuneWrapper(learner_svm, resampling = inner, par.set = ps, 
                               control = tuning_method, show.info = TRUE,
                               measures = list(auc))
```

### Executing everything in parallel

Now we have everything ready to execute the nested cross-validation. To
reduce runtime, we want to run it in parallel. `mlr` comes with an
integrated parallel function in the `parallelMap` package. It lets us
not only choose the type of parallelism (“socket”, “multicore”, etc.)
but also the level that we want to parallelize (here we choose the
tuning level, i.e. `"mlr.tuneParams"`). This means we can choose whether
the hyperparameter tuning should be parallelized or the performance
estimation in the outer level.

We set two seeds here: One for the creating of the resampling partitions
for which we can use `set.seed()` as it is created before the parallel
processes. The `mc.set.seed = TRUE` applies to the random tuning
combinations that are chosen within the tuning level. To make them
reproducible for future runs, we need to set this option.

Setting `extract = getTuneResult` argument also returns the fitted
models of every outer level fold so that we can do a possible
investigation if desired.

``` r
library(parallelMap)

parallelStart(mode = "multicore", level = "`mlr`.tuneParams", 
              cpus = 4, mc.set.seed = TRUE)

set.seed(12345)
resa_svm_spatial <- resample(wrapper_ksvm, spatial.task,
                             resampling = outer, extract = getTuneResult,
                             show.info = TRUE, measures = list(auc))

parallelStop()

# Resampling: repeated spatial cross-validation
# Measures:             auc
# [Tune] Started tuning learner classif.ksvm for parameter set:
#          Type len Def    Constr Req Tunable Trafo
# C     numeric   -   - -12 to 15   -    TRUE     Y
# sigma numeric   -   -  -15 to 6   -    TRUE     Y
# With control class: TuneControlRandom
# Imputation value: -0
# Mapping in parallel: mode = multicore; cpus = 4; elements = 50.
# [Tune] Result: C=617; sigma=0.000755 : auc.test.mean=0.6968159
# [Resample] iter 1:    0.5404151
```

The output of the first fold tells us the following:

The best combination of `C` and `sigma` out of the 50 tested ones is:

`[Tune] Result: C=617; sigma=0.000755 : auc.test.mean=0.6968159`

Subsequently, these two values have been used to fit a model on the
training set of the first fold. This model then achieved an AUROC value
of 0.5404151 on the respective test set. Only this value counts towards
the performance of the model. The AUROC measure from the tuning level
(0.6968159) is not used in any way. It just means that the winning
combination reached this value during tuning. As you see, there can be
major differences between the performance achieved during tuning to what
is then achieved with the same hyperparameters on the outer performance
estimation level.

This procedure is then applied to the remaining 499 folds (5 folds \*
100 repetitions).

Notes
=====

As I experienced that a lot of people are confused about the difference
between cross-validation, its purpose and its relation to the actual
prediction that one wants to do on a new data set:

Everything that has been done here is only a performance estimate of 500
different training + prediction runs. I results can be visualized in a
boxplot or similar or one can take the median or mean value to make a
statement about the average performance of the model.

The actual part of training a model and predicting it to a new data set
is a completely different step. There, one model is trained on the
complete data set. The hyperparameters again are estimated in a new
tuning procedure and the winning setting is used for the training. There
is no relation to the tuning part of the cross-validation.

References [references]
==========

Bergstra, James, and Yoshua Bengio. 2012. “Random Search for
Hyper-Parameter Optimization.” *J. Mach. Learn. Res.* 13 (February).
JMLR.org:281–305. <http://dl.acm.org/citation.cfm?id=2188385.2188395>.

Brenning, Alexander. 2012. “Spatial Cross-Validation and Bootstrap for
the Assessment of Prediction Rules in Remote Sensing: The R Package
Sperrorest.” In *2012 IEEE International Geoscience and Remote Sensing
Symposium*. IEEE. <https://doi.org/10.1109/igarss.2012.6352393>.

Hsu, Chih-wei, Chih-chung Chang, and Chih-Jen Lin. 2003. *A Practical
Guide to Support Vector Classification, Department of Computer Science
National Taiwan University, Taipei 106, Taiwan*.

Richter, Jakob. 2017. *MlrHyperopt: Easy Hyperparameter Optimization
with mlr and mlrMBO*. <http://doi.org/10.5281/zenodo.896269>.
