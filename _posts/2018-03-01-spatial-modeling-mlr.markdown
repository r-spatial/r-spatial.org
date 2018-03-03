---
author: Patrick Schratz
biblio-style: apalike
bibliography: ../bibs/spatial\_modeling\_`mlr`.bib
categories: r
comments: True
date: 03 March, 2018
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
more than 100 modeling packages. In comparison to `sperrorest` it shines
by providing the option to easily tune hyperparameters. For now, only
the most common spatial partitioning approach has been integrated It
uses k-means clustering to create spatially disjoint training and test
partitions (see Brenning ([2012](#ref-sperrorest))). In this blog post a
practical guidance on performing nested spatial cross-validation using
`mlr` is given. SVM was chosen as the algorithm as it is widely know and
always needs to be tuned to achieve good performance. Although the
tuning effect of models with meaningful default hyperparameter values
(e.g. Random Forest) is often marginal, one should always conduct a
hyperparameter tuning as the specific effect is not known a priori.

Everything in `mlr` is build upon the following steps:

-   create a task (describes the data),
-   tune hyperparameters (optional),
-   model training,
-   prediction to new dataset.

When model performance is to be estimated, the procedure is conducted
hundreds of times to reduce variance among different training + predict
arrangements. It essentially mimics the situation of applying the fitted
model on hundreds of different unknown test datasets. A different
performance will be returned for each try. However, in reality usually
no in-situ data exists for so many test datasets. That’s the reason thy
the existing dataset is split into subsets for which validation
information is available.

Creating a task
===============

The “Task” in `mlr` essentially stores all information around your
dataset: The type of the response variable, whether its a
supervised/unsupervised classification problem (if it is a
classification one), whether the “Task” is spatial or non-spatial
(i.e. whether it contains a spatial reference, i.e. coordinates) and
many more information.

The example “Task” for spatial applications in `mlr` used the `ecuador`
dataset. This dataset from [Jannes
Muenchow](http://www.geographie.uni-jena.de/Muenchow.html) also comes
with `sperrorest`. Since the integration is quite new, we need to use
the development version of `mlr` from Github.

``` r
devtools::install_github("mlr-org/mlr")

library("mlr")
```

First a task needs to be created. Luckily, the built-in datasets of
`mlr` are already in a task structure. Check sections
[Task](https://%60mlr%60-org.github.io/%60mlr%60-tutorial/devel/html/task/index.html)
in the `mlr-tutorial` if you need to build one from scratch. To make it
a [spatial
task](https://%60mlr%60-org.github.io/%60mlr%60-tutorial/devel/html/handling_of_spatial_data/index.html),
you need to provide the coordinates of the dataset in argument
`coordinates` of the task. They will later be used for the spatial
partitioning of the dataset in the spatial cross-validation.

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

We are dealing with a supervised classification problem that has 751
observations, 10 numeric predictors, the response is “slides” and has a
distribution of 500 positive and 251 negative detections.

Now that task has been created, we need to set up everything for the
nested spatial cross-validation. We will use a 5-fold 100 times repeated
cross-validation in the outer level (in which the performance is
estimated) and again a five folds for partitioning in the inner level
(where the hyperparameter tuning is conducted).

Specification of the learner
============================

The SVM implementation in the `kernlab` package is used in this example.

Create the learner:

``` r
learner_svm = makeLearner("classif.ksvm", predict.type = "prob")
```

The syntax is always the same in `mlr`: The prefix always specifies the
task type, e.g. “classif” or “regr”. There are more options to choose
from, see [Task
types](https://mlr-org.github.io/mlr-tutorial/devel/html/task/index.html).

As the response variable in this example is binary, we set
`predict.type = "prob"` to tell the algorithm that we want to predict
probabilities.

Setting the tuning method and its space
=======================================

For the tuning tow things need to be done:

1.  Selection of the tuning method
2.  Setting of the tuning space limits

There are multiple options in `mlr`, see the section on
[tuning](https://pat-s.github.io/%60mlr%60/articles/tutorial/devel/tune.html#specifying-the-optimization-algorithm)
in the `mlr-tutorial`.

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
space and the algorithm characteristics but I generally recommend not to
use less than 50.

Next, the tuning limits of the hyperparameters `C` and `sigma` are
defined:

``` r
ps = makeParamSet(makeNumericParam("C", lower = -5, upper = 15,
                                   trafo = function(x) 2 ^ x),
                  makeNumericParam("sigma", lower = -15, upper = 3,
                                   trafo = function(x) 2 ^ x))
```

Similar to the tuning budget, no scientific backed up limits exist in
which a tuning should be conducted. Here the limits recommended by Hsu,
Chang, and Lin ([2003](#ref-hsu2003)) are used. The problem of
specifying tuning limits applies to all machine-learning models. [Jakob
Richter](https://www.statistik.tu-dortmund.de/richter.html) is working
on a valuable project that establishes a database showing which limits
were chosen by other users (Richter [2017](#ref-mlrhyperopt)). This can
then serve as a reference point when searching tuning limits for an
algorithm.

Setting the resampling method
=============================

Now that the tuning method and its tuning space have been defined, the
resampling method for the CV that should be used needs to be set.

This needs to be done twice:

1.  For the performance estimation level (outer level)
2.  For the tuning level (inner level) in which the hyperparameters for
    the outer level are optimized

In both cases we want to use spatial cross-validation (`SpCV`). First,
we set it for the tuning level.

``` r
inner = makeResampleDesc("SpCV", iters = 5)
```

This setting means the following: Five folds will be used (`iters = 5`)
and, as we specified no repetition argument, one repetition will be
used. Note that if “SpCV” is specified, always only one repetition will
be used. If more repetitions should be used, one needs to use “SpRepCV”
(see also below). The chosen setting means that every random setting of
hyperparameters is applied once on each fold (5 in total). The
performance of all folds is stored and the combination with the best
mean value across all folds will be chosen as the “winner”.

It will be then used on the respective fold of the performance
estimation level (that still needs to be specified). For this level,
again five folds will be used but this time with the arrangement will be
repeated 100 times to reduce variance introduced by partitioning. Note
that this time “SpRepCV” needs to be chosen and the `iters` argument
changes to `folds`.

``` r
outer = makeResampleDesc("SpRepCV", folds = 5, rep = 100)
```

Next, a wrapper function is needed that uses the specified learner and
tells `mlr` that hyperparameter tuning should be performed. This
function is then plugged into the actual `resample()` call of `mlr`.
Luckily, `mlr` already comes with an integrated wrapper function:

``` r
wrapper_ksvm = makeTuneWrapper(learner_svm, resampling = inner, par.set = ps, 
                               control = tuning_method, show.info = TRUE,
                               measures = list(auc))
```

### Executing everything in parallel

Now everything is ready to execute the nested cross-validation. To
reduce runtime, we want to run it in parallel. `mlr` comes with an
integrated parallel function in the `parallelMap` package. It lets not
only choose the type of parallelism (“socket”, “multicore”, etc.) but
also the level that should be parallelized (here the tuning level is
selected, i.e. “mlr.tuneParams”). Choosing the parallelization level
means whether the hyperparameter tuning should be parallelized (the
chosen iterations) or the performance estimation in the outer level
(number of total folds).

Two seeds need to be set here:

1.  A seed for the creation of the resampling partitions.`set.seed()`
    can be used here as it is created before the parallel processes.
2.  For the seeding of the tested hyperparameter settings,
    `mc.set.seed = TRUE` needs to be used as this step is executed in
    parallel.

Additionally, the `extract = getTuneResult` option returns the fitted
models of every fold of the performance estimation so that a possible
investigation can be conducted later on.

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
# 
# [...]
```

The output of the first fold tells the following:

The best setting of `C` and `sigma` out of the 50 tested is:

`[Tune] Result: C=617; sigma=0.000755 : auc.test.mean=0.6968159`

Subsequently, these two values have been used to fit a model on the
training set of the first fold at the performance estimation level..
This model then achieved an AUROC value of 0.5404151 on the respective
test set. Only this value counts towards the performance of the model.
The AUROC measure from the tuning level (0.6968159) does not contribute
to the final performance estimate! It just means that the winning
hyperparameter setting reached this value during tuning. Apparently,
there can be major differences between the performance achieved during
tuning compared with the performance estimation level.

This procedure is then applied to the remaining 499 folds (5 folds \*
100 repetitions).

A personal note
===============

I experienced that a lot of people are confused about the difference
between cross-validation, its purpose and its relation to the actual
prediction that is desired to be done on a new dataset:

Everything that has been shown here is only a performance estimate of
500 different training + prediction runs. The results can be visualized
in a boxplot or similar or one can take the median or mean value to make
a statement about the average performance of the model.

The actual part of training a model and predicting it to a new dataset
(with the aim of creating a spatial prediction map) is a completely
different step. There, one model is trained on the complete dataset. The
hyperparameters again are estimated in a new tuning procedure and the
winning setting is used for the training. There is no relation to the
tuning part of the cross-validation.

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
