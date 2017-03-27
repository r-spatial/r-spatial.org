---
layout: post
title:  "Spring School on “Statistical analysis of hyperspectral and high-dimensional remote-sensing data using R”: a report"
date:  "25 March, 2017"
comments: true
author: Anna Schoch
categories: r
---

The Spring School on “Statistical analysis of hyperspectral and high-dimensional remote-sensing data using R”, held at the University of Jena, March 13-17, 2017, was organized by the GIScience group, led by [Prof. Alexander Brenning](http://www.geographie.uni-jena.de/Brenning.html) and two researchers from the GIScience research group, [Patrick Schratz](https://pat-s.github.io/) and [Dr. Jannes Münchow](http://www.geographie.uni-jena.de/Muenchow.html).  

The school brought together a diverse group of 28 researchers (e.g. geoscientists, forestry, environmental studies) at different scientific levels (graduate students, PhD, postdoc, professor) from all over the world as far as Chile, Peru, Turkey, and Bosnia & Herzegowina. Overall, eight german and 16 non-german participants (20 male, 8 female) took part in this event. During five days the participants were introduced to the theoretical background of hyperspectral remote sensing data and learned in numerous hands-on sessions how to analyse and illustrate spatial data in R. The Spring School was organized within the [LIFE Healthy Forest](http://www.lifehealthyforest.com/) project and supported by the [Michael Stifel Center Jena](http://www.mscj.uni-jena.de/).  

In this short blog-post I will give a quick overview of the many, many things we learned during this intense “spatial stats-and-R-week”.

![](/images/spring-school-jena1.jpg)
*Participants and organizers of the Spring School on “Statistical analysis of hyperspectral and high-dimensional remote-sensing data using R” in Jena, © H. Petschko*

# Day 1

On the first day of the summer school the participants obtained a theoretical introduction to hyperspectral remote-sensing data with examples focusing on the application of hyperspectral data in forest research.  
[Marco Peña](http://geografia.uahurtado.cl/index.php/2013/04/08/marco-pena/) from the Alberto Hurtado University in Chile gave a lecture on “Introduction to hyperspectral remote sensing” which brought everyone to the same level.  
This very comprehensive introduction was followed by a talk on hyperspectral applications exemplified on a study on forests in the Bialowieza Forest in eastern Poland by [Aneta Modzelewska](https://www.ibles.pl/en/web/guest/searchresult2?p_p_id=62_INSTANCE_4tsRtmXIKRuY&p_p_mode=view&_62_INSTANCE_4tsRtmXIKRuY_struts_action=/journal_articles/view&_62_INSTANCE_4tsRtmXIKRuY_groupId=10180&_62_INSTANCE_4tsRtmXIKRuY_articleId=6409308&indexMode=true&group=10180&highlighting=Modzelewska) from the Forest Research Institute in Warsaw.  
The last talk on the first day was by [Dr. Henning Buddenbaum](https://www.uni-trier.de/index.php?id=49651) (University of Trier) on “Hyperspectral remote sensing for measuring biochemical leaf parameters in forests”.  
Dr. Buddenbaum is involved in the Science Advisory Group – Forests and Natural Ecosystems in the EnMAP mission, a German hyperspectral satellite mission aiming at monitoring and characterising the Earth’s environment globally.

![](/images/spring-school-jena6.jpg)
*Lecture by Prof. A. Brenning on “Statistical and machine learning in remote sensing”, © H. Petschko*

# Day 2

The second day was filled with hands-on R sessions. In a first session by Patrick Schratz we learned about his “must know” features of R, namely Rmarkdown, the apply-family and pipes.  
This was followed by two session focusing on the usage of R as a GIS. Dr. Jannes Münchow, who developed the package [RQGIS](http://jannes-m.github.io/RQGIS/index.html), an interface between R and QGIS which allows the user to access QGIS algorithms from within R.  
Afterwards we were introduced to the R package [mapview](https://github.com/environmentalinformatics-marburg/mapview), by its author, Dr. [Tim Appelhans](https://github.com/tim-salabim). 
Mapview is a GIS-like interactive graphing tool that is directly accessible within RStudio (or the web browser, if you are not using RStudio). 
It is especially helpful if you want to quickly do a visual check whether a certain analysis has produced reasonable results.

![](/images/spring-school-jena2.jpg)
*Solving R-problems with Dr. Jannes Münchow, © H. Petschko*

# Day 3

The third day started with a lecture and hands-on session on “Statistical and machine learning in remote sensing” by Prof. Alexander Brenning with a focus on linear discriminant analysis, support vector machine and random forest. 
A short overview of these statistical modeling methods and the application in R including a comprehensive tutorial can be found [here](http://r-spatial.org/r/2017/03/13/sperrorest-update.html).  
In the afternoon, [Dr. Thomas Bocklitz](https://www.ipc.uni-jena.de/members.php?lang=en&id=14) presented a very different perspective in the application of spectral data analysis in histopathology. Afterwards, the participants had a chance to discuss their own research involving spatial modeling techniques or R-problem with the group and the experts from the GIScience group in Jena.

![](/images/spring-school-jena3.jpg)
*Open session during the Day3 of the Spring School to discuss research projects of the participants, © H. Petschko*

# Day 4

On the fourth day, Partick Schratz briefly introduced the [hsdar](https://cran.r-project.org/web/packages/hsdar/vignettes/Hsdar-intro.pdf) package developed by [Dr. Lukas Lehnert](https://www.uni-marburg.de/fb19/fachgebiete/klimageographie/lehnertl/) from University of Marburg. It can be used for processing and analysis on hyperspectral data in R.  
Prof. Brenning focused in his second session further on the assessment of model accuracy (non-spatial and spatial validation methods, variable importance) using the [sperrorest](https://pat-s.github.io/sperrorest/index.html) package and dealing with high dimensionality in linear regression.

![](/images/spring-school-jena4.jpg)
*Discussing sampling designs with Prof. A. Brenning, © H. Petschko*

![](/images/spring-school-jena5.jpg)
*Introduction to parallel processing in R with Patrick Schratz, © H. Petschko*

# Day 5 (Thuringian Forest excursion)

On the last day, we visited a monitoring site and a site with tornado damage (see images below) from 2016 in the Thuringian Forest together with three experts from the official authority “ThüringenForst”.  
In conclusion, the Spring School was a great event with many fruitful hands-on R-sessions during which the participants could learn helpful tricks in R, how to use R as a GIS and about statistical and machine learning in R. Hopefully there will be more academic “schools” like this one to follow in the future (maybe even with a thematic focus on geomorphology or natural hazards).


![](/images/spring-school-jena7.jpg)
*Tornado damage in the Thuringian Forest from September 2016 © P. Schratz*

![](/images/spring-school-jena8.jpg)
*Field trip to the Thuringian Forest, © X. Tagle*
