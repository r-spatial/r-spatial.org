---
author: Alexander Brenning, Patrick Schratz
biblio-style: apalike
bibliography: ../bibs/Biblio-sperrorest.bib
categories: r
comments: True
date: Mar 13, 2017
layout: post
link-citations: True
meta-json: {"layout":"post","link-citations":true,"bibliography":"../bibs/Biblio-sperrorest.bib","categories":"r","date":"13 March, 2017","author":"Alexander Brenning, Patrick Schratz","comments":true,"title":"Spatial Modeling Using Statistical Learning Techniques","biblio-style":"apalike"}
title: Spatial Modeling Using Statistical Learning Techniques
---

*- This post was updated to sperrorest v2.0.0 in July 2017 -*

Introduction
============

Geospatial data scientists often make use of a variety of statistical
and machine learning techniques for spatial prediction in applications
such as landslide susceptibility modeling (Goetz et al.
[2015](#ref-Goetz2015)) or habitat modeling (Knudby, Brenning, and
LeDrew [2010](#ref-Knudby2010)). Novel and often more flexible
techniques promise improved predictive performances as they are better
able to represent nonlinear relationships or higher-order interactions
between predictors than less flexible linear models.

Nevertheless, this increased flexibility comes with the risk of possible
over-fitting to the training data. Since nearby spatial observations
often tend to be more similar than distant ones, traditional random
cross-validation is unable to detect this over-fitting whenever spatial
observations are close to each other (e.g. Brenning
([2005](#ref-Brenning2005))). Spatial cross-validation addresses this by
resampling the data not completely randomly, but using larger spatial
regions. In some cases, spatial data is grouped, e.g. in remotely-sensed
land use mapping grid cells belonging to the same field share the same
management procedures and cultivation history, making them more similar
to each other than to pixels from other fields with the same crop type.

The [sperrorest](https://pat-s.github.io/sperrorest/index.html) package
provides a customizable toolkit for cross-validation (and bootstrap)
estimation using a variety of spatial resampling schemes. More so, this
toolkit can even be extended to spatio-temporal data or other complex
data structures. This blog post will walk you through a simple case
study, crop classification in central Chile (Peña and Brenning
[2015](#ref-Pena2015)).

Data and Packages
=================

As a case study we will carry out a supervised classification analysis
using remotely-sensed data to predict fruit-tree crop types in central
Chile. This data set is a subsample of data from (Peña and Brenning
[2015](#ref-Pena2015)).

    library(pacman)
    p_load(sperrorest)

    data("maipo", package = "sperrorest")

The remote-sensing predictor variables were derived from an image times
series consisting of eight Landsat images acquired throughout the
(southern hemisphere) growing season. The data set includes the
following variables:

**Response**  
- `croptype`: response variable (factor) with 4 levels: ground truth
information

**Predictors**  
- `b`\[12-87\]: spectral data, e.g. b82 = image date \#8, spectral band
\#2  
- `ndvi`\[01-08\]: Normalized Difference Vegetation Index, e.g. \#8 =
image date \#8  
- `ndwi`\[01-08\]: Normalized Difference Water Index, e.g. \#8 = image
date \#8

**Others**  
- `field`: field identifier (grouping variable - not to be used as
predictor)  
- `utmx`, `utmy`: x/y location; not to be used as predictors

All but the first four variables of the data set are predictors; their
names are used to construct a formula object:

    predictors <- colnames(maipo)[5:ncol(maipo)]
    # Construct a formula:
    fo <- as.formula(paste("croptype ~", paste(predictors, collapse = "+")))

Modeling
========

Here we will take a look at a few classification methods with varying
degrees of computational complexity and flexibility. This should give
you an idea of how different models are handled by `sperrorest`,
depending on the characteristics of their fitting and prediction
methods. Please refer to (James et al. [2013](#ref-James2013)) for
background information on the models used here.

Linear Discriminant Analysis (LDA)
----------------------------------

LDA is simple and fast, and often performs surprisingly well if the
problem at hand is 'linear enough'. As a start, let's fit a model with
all predictors and using all available data:

    p_load(MASS)
    fit <- lda(fo, data = maipo)

Predict the croptype with the fitted model and calculate the
misclassification error rate (MER) on the training sample:

    pred <- predict(fit, newdata = maipo)$class
    mean(pred != maipo$croptype)

    ## [1] 0.0437

But remember that this result is over-optimistic because we are re-using
the training sample for model evaluation. We will soon show you how to
do better with cross-validation.

We can also take a look at the confusion matrix but again, this result
is overly optimistic:

    table(pred = pred, obs = maipo$croptype)

    ##         obs
    ##   pred  crop1 crop2 crop3 crop4
    ##   crop1  1294     8     4    37
    ##   crop2    50  1054     4    44
    ##   crop3     0     0  1935     6
    ##   crop4    45   110    29  3093

Classification Tree
-------------------

Classification and regresion trees (CART) take a completely different
approach---they are based on yes/no questions in the predictor variables
and can be referred to as a binary partitioning technique. Fit a model
with all predictors and default settings:

    p_load(rpart)

    fit <- rpart(fo, data = maipo)

    ## optional: view the classiciation tree
    # par(xpd = TRUE)
    # plot(fit)
    # text(fit, use.n = TRUE)

Again, predict the croptype with the fitted model and calculate the
average MER:

    pred <- predict(fit, newdata = maipo, type = "class")
    mean(pred != maipo$croptype)

    ## [1] 0.113

Here the `predict` call is slightly different. Again, we could calculate
a confusion matrix.

    table(pred = pred, obs = maipo$croptype)

    ##         obs
    ##   pred  crop1 crop2 crop3 crop4
    ##   crop1  1204    66     0    54
    ##   crop2    47   871    38   123
    ##   crop3    38     8  1818    53
    ##   crop4   100   227   116  2950

RandomForest
------------

Bagging, bundling and random forests build upon the CART technique by
fitting many trees on bootstrap resamples of the original data set
(Breiman [1996](#ref-Breiman1996)) (Breiman [2001](#ref-Breiman2001))
(Hothorn and Lausen [2005](#ref-Hothorn2005)). They differ in that
random forest also samples from the predictors, and bundling adds an
ancillary classifier for improved classification. We will use the
nowadays widely used `randomForest()` here.

    p_load(randomForest)

    fit <- randomForest(fo, data = maipo, coob = TRUE)
    fit

    ## 
    ## Call:
    ##  randomForest(formula = fo, data = maipo, coob = TRUE) 
    ##                Type of random forest: classification
    ##                      Number of trees: 500
    ## No. of variables tried at each split: 8
    ## 
    ##         OOB estimate of  error rate: 0.57%
    ## Confusion matrix:
    ##       crop1 crop2 crop3 crop4 class.error
    ## crop1  1382     2     0     5     0.00504
    ## crop2     1  1163     0     8     0.00768
    ## crop3     0     0  1959    13     0.00659
    ## crop4     7     5     3  3165     0.00472

Let's take a look at the MER achieved on the training sample:

    pred <- predict(fit, newdata = maipo, type = "class")
    mean(pred != maipo$croptype)

    ## [1] 0

    table(pred = pred, obs = maipo$croptype)

    ##         obs
    ##   pred  crop1 crop2 crop3 crop4
    ##   crop1  1389     0     0     0
    ##   crop2     0  1172     0     0
    ##   crop3     0     0  1972     0
    ##   crop4     0     0     0  3180

Isn't this amazing? Only one grid cell is misclassified by the bagging
classifier! Even the OOB (out-of-bag) estimate of the error rate is &lt;
1%.  
Too good to be true? We'll see...

Cross-Validation Estimation of Predictive Performance
=====================================================

Of course we can't take the MER on the training set too seriously---it
is biased. But we've heard of cross-validation, in which disjoint
subsets are used for model training and testing. Let's use `sperrorest`
for cross-validation.

Also, at this point we should highlight that the observations in this
data set are pixels, and multiple grid cells belong to the same field.
In a predictive situation, and when field boundaries are known (as is
the case here), we would want to predict the same class for all grid
cells that belong to the same field. Here we will use a majority filter.
This filter ensures that the final predicted class type of every field
is the most often predicted croptype within one field.

Linear Discriminant Analysis (LDA)
----------------------------------

First, we need to create a wrapper predict method for LDA for
`sperrorest()`. This is necessary in order to accomodate the majority
filter, and also because class predictions from `lda`'s predict method
are hidden in the `$class` component of the returned object.

    lda_predfun <- function(object, newdata, fac = NULL) {
      
      p_load(nnet)
      majority <- function(x) {
        levels(x)[which.is.max(table(x))]
      }
      
      majority_filter <- function(x, fac) {
        for (lev in levels(fac)) {
          x[fac == lev] <- majority(x[fac == lev])
        }
        x
      }
      
      pred <- predict(object, newdata = newdata)$class
      if (!is.null(fac)) pred <- majority_filter(pred, newdata[, fac]) 
      return(pred)
    }

To ensure that custom predict-functions will work with `sperrorest()`,
we need to wrap all custom functions in one single function. Otherwise,
`sperrorest()` might fail during execution.

Finally, we can run `sperrorest()` with a non-spatial sampling setting
(`partition_cv()`). In this example we use a '100 repetitions - 5 folds'
setup to reduce the influence of random partitioning.

    res_lda_nsp <- sperrorest(fo, data = maipo, coords = c("utmx","utmy"), 
                              model_fun = lda,
                              pred_fun = lda_predfun, 
                              pred_args = list(fac = "field"),
                              smp_fun = partition_cv, 
                              smp_args = list(repetition = 50, nfold = 5),
                              progress = FALSE)

    summary(res_lda_nsp$error_rep)

    ##                    mean    sd   median   IQR
    ## train_error    3.40e-02 0.001 3.40e-02 0.001
    ## train_accuracy 9.66e-01 0.001 9.66e-01 0.001
    ## train_events   4.69e+03 0.000 4.69e+03 0.000
    ## train_count    3.09e+04 0.000 3.09e+04 0.000
    ## test_error     4.00e-02 0.002 4.00e-02 0.002
    ## test_accuracy  9.60e-01 0.002 9.60e-01 0.002
    ## test_events    1.17e+03 0.000 1.17e+03 0.000
    ## test_count     7.71e+03 0.000 7.71e+03 0.000

To run a spatial cross-validation at the field level, we can use
`partition_factor_cv()` as the sampling function. Since we are using 5
folds, we get a coarse 80/20 split of our data. 80% will be used for
training, 20% for testing our trained model.

To take a look where our training and tests sets will be partitioned on
each fold, we can plot them. The red colored points represent the test
set in each fold, the black colored points the training set. Note that
because we plotted over 7000 points, overplotting occurs and since the
red crosses are plotted after the black ones, it seems visually that way
more than \~20% of red points exist than it is really the case.

    resamp <- partition_factor_cv(maipo, nfold = 5, repetition = 1:1, fac = "field")
    plot(resamp, maipo, coords = c("utmx","utmy"))

![](..//images/resamp-plot.png)

Subsequently, we have to specify the location of the fields
(`fac = "field"`) in the prediction arguments (`pred_args`) and sampling
arguments (`smp_args`) in `sperrorest()`.

    res_lda_sp <- sperrorest(fo, data = maipo, coords = c("utmx","utmy"), 
                             model_fun = lda,
                             pred_fun = lda_predfun, 
                             pred_args = list(fac = "field"),
                             smp_fun = partition_factor_cv,
                             smp_args = list(fac = "field", repetition = 1:50, nfold = 5),
                             benchmark = TRUE, progress = FALSE)
    res_lda_sp$benchmark$runtime_performance

    summary(res_lda_sp$error_rep)

    ##                    mean      sd   median     IQR
    ## train_error    2.95e-02 0.00177 2.97e-02 0.00261
    ## train_accuracy 9.70e-01 0.00177 9.70e-01 0.00261
    ## train_events   4.69e+03 0.00000 4.69e+03 0.00000
    ## train_count    3.09e+04 0.00000 3.09e+04 0.00000
    ## test_error     6.65e-02 0.00807 6.59e-02 0.01083
    ## test_accuracy  9.33e-01 0.00807 9.34e-01 0.01083
    ## test_events    1.17e+03 0.00000 1.17e+03 0.00000
    ## test_count     7.71e+03 0.00000 7.71e+03 0.00000

RandomForest
------------

In the case of Random Forest, the customized `pred_fun` looks as
follows; it is only required because of the majority filter, without it,
we could just omit the `pred_fun` and `pred_args` arguments below.

    rf_predfun <- function(object, newdata, fac = NULL) {
      
      p_load(nnet)
      majority <- function(x) {
        levels(x)[which.is.max(table(x))]
      }
      
      majority_filter <- function(x, fac) {
        for (lev in levels(fac)) {
          x[fac == lev] <- majority(x[fac == lev])
        }
        x
      }
      
      pred <- predict(object, newdata = newdata)
      if (!is.null(fac)) pred <- majority_filter(pred, newdata[,fac]) 
      return(pred)
    }

    res_rf_sp <- sperrorest(fo, data = maipo, coords = c("utmx","utmy"), 
                            model_fun = randomForest,
                            pred_fun = rf_predfun,
                            pred_args = list(fac = "field"),
                            smp_fun = partition_factor_cv,
                            smp_args = list(fac = "field",
                                            repetition = 1:50, nfold = 5),
                            benchmark = TRUE, progress = 2)

    ## Mon Feb 27 20:56:01 2017 Repetition 1 
    ## Mon Feb 27 20:57:12 2017 Repetition 2 
    ## Mon Feb 27 20:58:20 2017 Repetition 3 
    ## Mon Feb 27 20:59:29 2017 Repetition 4 
    ## Mon Feb 27 21:00:36 2017 Repetition 5 
    ## Mon Feb 27 21:01:46 2017 Repetition 6 
    ## Mon Feb 27 21:02:55 2017 Repetition 7 
    ## Mon Feb 27 21:04:01 2017 Repetition 8 
    ## Mon Feb 27 21:05:07 2017 Repetition 9 
    ## Mon Feb 27 21:06:16 2017 Repetition 10 
    ## Mon Feb 27 21:07:23 2017 Repetition 11 
    ## Mon Feb 27 21:08:30 2017 Repetition 12 
    ## Mon Feb 27 21:09:38 2017 Repetition 13 
    ## Mon Feb 27 21:10:45 2017 Repetition 14 
    ## Mon Feb 27 21:11:53 2017 Repetition 15 
    ## Mon Feb 27 21:13:01 2017 Repetition 16 
    ## Mon Feb 27 21:14:09 2017 Repetition 17 
    ## Mon Feb 27 21:15:16 2017 Repetition 18 
    ## Mon Feb 27 21:16:23 2017 Repetition 19 
    ## Mon Feb 27 21:17:31 2017 Repetition 20 
    ## Mon Feb 27 21:18:39 2017 Repetition 21 
    ## Mon Feb 27 21:19:46 2017 Repetition 22 
    ## Mon Feb 27 21:20:53 2017 Repetition 23 
    ## Mon Feb 27 21:22:03 2017 Repetition 24 
    ## Mon Feb 27 21:23:13 2017 Repetition 25 
    ## Mon Feb 27 21:24:23 2017 Repetition 26 
    ## Mon Feb 27 21:25:32 2017 Repetition 27 
    ## Mon Feb 27 21:26:39 2017 Repetition 28 
    ## Mon Feb 27 21:27:47 2017 Repetition 29 
    ## Mon Feb 27 21:28:55 2017 Repetition 30 
    ## Mon Feb 27 21:30:03 2017 Repetition 31 
    ## Mon Feb 27 21:31:11 2017 Repetition 32 
    ## Mon Feb 27 21:32:18 2017 Repetition 33 
    ## Mon Feb 27 21:33:25 2017 Repetition 34 
    ## Mon Feb 27 21:34:33 2017 Repetition 35 
    ## Mon Feb 27 21:35:40 2017 Repetition 36 
    ## Mon Feb 27 21:36:47 2017 Repetition 37 
    ## Mon Feb 27 21:37:54 2017 Repetition 38 
    ## Mon Feb 27 21:39:02 2017 Repetition 39 
    ## Mon Feb 27 21:40:09 2017 Repetition 40 
    ## Mon Feb 27 21:41:17 2017 Repetition 41 
    ## Mon Feb 27 21:42:24 2017 Repetition 42 
    ## Mon Feb 27 21:43:31 2017 Repetition 43 
    ## Mon Feb 27 21:44:38 2017 Repetition 44 
    ## Mon Feb 27 21:45:46 2017 Repetition 45 
    ## Mon Feb 27 21:46:54 2017 Repetition 46 
    ## Mon Feb 27 21:48:01 2017 Repetition 47 
    ## Mon Feb 27 21:49:07 2017 Repetition 48 
    ## Mon Feb 27 21:50:15 2017 Repetition 49 
    ## Mon Feb 27 21:51:21 2017 Repetition 50 
    ## Mon Feb 27 21:52:27 2017 Done.

    res_rf_sp$benchmark$runtime_performance
    ## Time difference of 56.4 mins

    summary(res_rf_sp$error_rep$test_error)

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##  0.0630  0.0827  0.0871  0.0868  0.0928  0.1100

    summary(res_rf_sp$error_rep$test_accuracy)

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   0.890   0.907   0.913   0.913   0.917   0.937

What a surprise! RandomForest classification isn't that good after all,
if we acknowledge that in 'real life' we wouldn't be making predictions
in situations where the class membership of other grid cells in the same
field is known in the training stage. So spatial dependence does matter.

Usage Advices
=============

Given all the different sampling functions and the required custom
predict functions (e.g. `rf_predfun()`) in this example, you might be a
little confused which function to use for your use case.  
If you want to do a "normal", i.e. **non-spatial cross-validation** we
recommend to use `partition_cv()` as `smp_fun` in `sperrorest()`. If you
want to perform a **spatial cross-validation** (and you do not have a
grouping structure like fields in this example), `partition_kmeans()`
takes care of spatial partitioning. In most cases you can simply use the
generic `predict()` method for your model (= skip this argument in
`sperrorest()`). Check our "custom model and predict functions" vignette
for more information on cases where adjustments are needed.

For further questions/issues, please open an issue at our [Github
repo](https://github.com/pat-s/sperrorest).

References [references]
==========

Breiman, Leo. 1996. “Bagging Predictors.” *Machine Learning* 24 (2).
Springer Nature: 123–40.
doi:[10.1007/bf00058655](https://doi.org/10.1007/bf00058655).

———. 2001. “Random Forests.” *Machine Learning* 45 (1). Springer Nature:
5–32.
doi:[10.1023/a:1010933404324](https://doi.org/10.1023/a:1010933404324).

Brenning, A. 2005. “Spatial Prediction Models for Landslide Hazards:
Review, Comparison and Evaluation.” *Natural Hazards and Earth System
Science* 5 (6). Copernicus GmbH: 853–62.
doi:[10.5194/nhess-5-853-2005](https://doi.org/10.5194/nhess-5-853-2005).

Goetz, J.N., A. Brenning, H. Petschko, and P. Leopold. 2015. “Evaluating
Machine Learning and Statistical Prediction Techniques for Landslide
Susceptibility Modeling.” *Computers & Geosciences* 81 (August).
Elsevier BV: 1–11.
doi:[10.1016/j.cageo.2015.04.007](https://doi.org/10.1016/j.cageo.2015.04.007).

Hothorn, Torsten, and Berthold Lausen. 2005. “Bundling Classifiers by
Bagging Trees.” *Computational Statistics & Data Analysis* 49 (4).
Elsevier BV: 1068–78.
doi:[10.1016/j.csda.2004.06.019](https://doi.org/10.1016/j.csda.2004.06.019).

James, Gareth, Daniela Witten, Trevor Hastie, and Robert Tibshirani.
2013. *An Introduction to Statistical Learning*. Springer New York.
doi:[10.1007/978-1-4614-7138-7](https://doi.org/10.1007/978-1-4614-7138-7).

Knudby, Anders, Alexander Brenning, and Ellsworth LeDrew. 2010. “New
Approaches to Modelling Fishhabitat Relationships.” *Ecological
Modelling* 221 (3). Elsevier BV: 503–11.
doi:[10.1016/j.ecolmodel.2009.11.008](https://doi.org/10.1016/j.ecolmodel.2009.11.008).

Peña, M.A., and A. Brenning. 2015. “Assessing Fruit-Tree Crop
Classification from Landsat-8 Time Series for the Maipo Valley, Chile.”
*Remote Sensing of Environment* 171 (December). Elsevier BV: 234–44.
doi:[10.1016/j.rse.2015.10.029](https://doi.org/10.1016/j.rse.2015.10.029).
