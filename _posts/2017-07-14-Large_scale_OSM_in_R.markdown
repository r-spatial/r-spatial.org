---
author: Konstantin Klemmer, Imperial College London
categories:
comments: True
date: 2017-07-14 00:00
meta-json: {"layout":"post","categories":"r","date":"29 November, 2016","author":"Edzer Pebesma","comments":true,"title":"Setting up large scale OSM environments for R using Osmosis and PostgreSQL with PostGIS"}
layout: post
title: "Setting up large scale OSM environments for R using Osmosis and PostgreSQL with PostGIS"
---
Importing **OpenStreetMap (OSM)** data into *R* can sometimes be rather
difficult, especially when it comes to processing large datasets. There
are some packages that aim at easy integration of OSM data, including
the very versatile `osmar` package, that allows you to scrape data
directly in *R* via the OSM API. Packages like `osmar`,`rgdal` or `sf`
also offer build-in functions to read the spatial data formats that OSM
data comes along with.

However, these packages reach their limits when it comes to larger
datasets and running the programmes on weak machines. I want to
introduce an easy way to set up an environment to process large OSM
datasets in R, using the *Java* application **Osmosis** and the
open-source database **PostgreSQL** with the **PostGIS** extension for
spatial data.

This tutorial was created using a **Asus Zenbook UX32LA** with a
**i5-4200U CPU**, **8 GB RAM** and a **250 GB SSD**, running on Windows
10. The data used has a size of **1.9 GB** (unzipped). Under this
setting, OSM data import using `osmar`, `rgdal` and `sf` takes up
several hours, if not days, especially if you want to continue using
your system. The following steps thus show a way to set up larger
spatial data environments using the PostgreSQL database scheme and how
to easily import and set up this data in *R*.

Getting OSM data
----------------

The place to extract large OSM datasets is the file dump **Planet.osm**,
which can be found here:
<https://wiki.openstreetmap.org/wiki/Planet.osm>

Here, we can download all available OSM data or search for extracts from
our area of interest. I am interested in downloading the most recent OSM
data for Greater London, which for instance is provided by
**Geofabrik**. This archive offers OSM data for predefined layers like
countries, states or urban areas. The London data that I will be using
in this tutorial can be found here:
<http://download.geofabrik.de/europe/great-britain/england/greater-london.html>

I download the file `greater-london-latest.osm.pbf`, conatining the
complete dataset for the Greater London area. Note that this file is
updated regularly.

Setting up PostgreSQL and PostGIS
---------------------------------

We now need to download and install **PostgreSQL** with the **PostGIS**
extension. A detailed explanation on how to install PostgreSQL can be
found here:
<https://wiki.postgresql.org/wiki/Detailed_installation_guides>

Make sure you note `username`, `password` and the `port` you use for the
installation. After PostgreSQL is installed on the system, PostGIS can
be added as described here:
<https://wiki.openstreetmap.org/wiki/PostGIS/Installation>

Now, open **pgAdmin** to set up your database. We can create new
databases by clicking on `Object` -- `Create` -- `Database`, inserting a
name of your choice, e.g. `London OSM`.

![](https://konstantinklemmer.github.io/images/blog/OSM_in_R/postgre_db.png)

My new database `London OSM` is now in place and can be prepared for
data import. We have to create two extensions to our database, using a
`SQL` script. We navigate into the new database and open the script
command line by clicking on `Object` -- `CREATE Script` and execute two
commands:

-   `CREATE EXTENSION postgis;`
-   `CREATE EXTENSION hstore;`

![](https://konstantinklemmer.github.io/images/blog/OSM_in_R/postgre_script.png)

These extensions should now show up when openng the `Extensions` path in
our `London OSM` database.

Setting up Osmosis and importing the data
-----------------------------------------

The tool connecting our dataset with PostgreSQL is called **Osmosis**.
It is a command line Java application and can be used to read, write and
manipulate OSM data. The latest stable version including detailed
installation information for different OS can be found here:
<https://wiki.openstreetmap.org/wiki/Osmosis> (Note that Osmosis
requires the Java Runtime Environment, which can be downloaded at
<https://java.com/download/>)

If you are using Windows, you can navigate into the Osmosis installation
folder, e.g. `C:\Program Files (x86)\osmosis\bin\`, and open
`osmosis.bat`. Double clicking this file opens the Osmosis command line.
To keep the Osmosis window open, create a shortcut to the `osmosis.bat`
file, open its properties and add `cmd /k` at the beginning of the
target in the shortcut tab. The Osmosis output should look like this:

![](https://konstantinklemmer.github.io/images/blog/OSM_in_R/osmosis_output.png)

We now have to prepare our **PostgreSQL** database for the OSM data
import (courtesy of Stackexchange user *zehpunktbarron*). Navigate back
into **pgAdmin** and the `OSM London` database and create a new script
via `Object` -- `CREATE Script`. Now, execute the `SQL` code that you
find in two of the files that you created when installing Osmosis. First
execute the code from
`[PATH_TO_OSMOSIS]\script\pgsnapshot_schema_0.6.sql` and afterwards the
code from
`[PATH_TO_OSMOSIS]\script\pgsnapshot_schema_0.6_linestring.sql`.

Now, add indices to the database to better process the data. Execute the
following `SQL` commands in the script:

-   `CREATE INDEX idx_nodes_tags ON nodes USING GIN(tags);`
-   `CREATE INDEX idx_ways_tags ON ways USING GIN(tags);`
-   `CREATE INDEX idx_relations_tags ON relations USING GIN(tags);`

We have now successfully prepared our database for the OSM import. Open
**Osmosis** and run the following command to import the previously
downloaded `.pbf` file:

`"[PATH_TO_OSMOSIS]\bin\osmosis" --read-pbf file="[PATH_TO_OSM_FILE]\greater-london-latest.osm.pbf" --write-pgsql`
`host="localhost" database="London OSM" user="YOUR_USERNAME" password="YOUR_PASSWORD"`

Note that if the `.pbf` file is larger, this process might take a while
-- also depending on the specs of your system. If the data import was
successful, this should give you an output that looks like this:

![](https://konstantinklemmer.github.io/images/blog/OSM_in_R/osmosis_import.png)

Accessing PostgreSQL databases in R
-----------------------------------

Our freshly imported database is now ready to be accessed via *R*.
Connecting to the PostgreSQL database requires the R package
`RPostgreSQL`. First, we load the PostgreSQL driver and connect to the
database using our credentials:

    require(RPostgreSQL)

    # LOAD POSTGRESQL DRIVER
    driver <- dbDriver("PostgreSQL")
    # CREATE CONNECTION TO THE POSTGRESQL DATABASE
    # THE CONNECTION VARIABLE WILL BE USED FOR ALL FURTHER OPERATIONS
    connection <- dbConnect(driver, dbname = "London OSM",
                     host = "localhost", port = 5432,
                     user = "YOUR_USERNAME", password = "YOUR_PASSWORD")

We can now check, whether we have successfully established a connection
to our database using a simple command:

    dbExistsTable(connection, "lines")

    ## [1] TRUE

We have now set up the environment to load OSM data into R flawlessly.
Note that queries using `RPostgreSQL` are written in the `SQL` syntax.
Further information on the use of the `RPostgreSQL` package can be found
here: <https://www.r-bloggers.com/using-postgresql-in-r-a-quick-how-to/>

Creating spatial data frames in R
---------------------------------

In the last step of this tutorial we will explore how to put the
accessed data to work and how to properly establish the geographical
reference. We first load data into the *R* environment, using a
`RPostgreSQL` query. The following query creates a `data.frame` with all
available OSM point data. We use the PostGIS command `ST_AsText` on the
`wkb_geometry` column to return the Well Known Text (WKT) geometries and
save it in the newly created column `geom`. After that, we delete the
now redundant `wkb_geometry` column.

    #LOAD POINT DATA FROM OSM DATABASE
    points <- dbGetQuery(connection, "SELECT * , ST_AsText(wkb_geometry) AS geom from points")
    points$wkb_geometry <- NULL

The `points` data frame contains all available OSM point data, including
the several different tagging schemes, which can be further explored
looking at OSMs' map features:
<https://wiki.openstreetmap.org/wiki/Map_Features>

    head(points)

    ##   ogc_fid osm_id                        name   barrier         highway
    ## 1       1      1 Prime Meridian of the World      <NA>            <NA>
    ## 2       2  99941                        <NA> lift_gate            <NA>
    ## 3       3 101831                        <NA>      <NA>        crossing
    ## 4       4 101833                        <NA>      <NA>        crossing
    ## 5       5 101839                        <NA>      <NA> traffic_signals
    ## 6       6 101843                        <NA>      <NA> traffic_signals
    ##    ref address is_in place man_made
    ## 1 <NA>    <NA>  <NA>  <NA>     <NA>
    ## 2 <NA>    <NA>  <NA>  <NA>     <NA>
    ## 3 <NA>    <NA>  <NA>  <NA>     <NA>
    ## 4 <NA>    <NA>  <NA>  <NA>     <NA>
    ## 5 <NA>    <NA>  <NA>  <NA>     <NA>
    ## 6 <NA>    <NA>  <NA>  <NA>     <NA>
    ##                                                other_tags
    ## 1              "historic"=>"memorial","memorial"=>"stone"
    ## 2                                                    <NA>
    ## 3 "crossing"=>"traffic_signals","crossing_ref"=>"pelican"
    ## 4                                    "crossing"=>"island"
    ## 5                                                    <NA>
    ## 6                                                    <NA>
    ##                           geom
    ## 1 POINT(-0.0014863 51.4779481)
    ## 2 POINT(-0.1553793 51.5231639)
    ## 3 POINT(-0.1470438 51.5356116)
    ## 4 POINT(-0.1588224 51.5350894)
    ## 5 POINT(-0.1526586 51.5375096)
    ## 6   POINT(-0.163653 51.534922)

Now, to get the geometry working, we can transform the data frame into a
spatial data frame using the `sf` package. Note that I have to set a
coordinate reference system (CRS), in this case the **WGS84**
projection:

    #SET COORDINATE SYSTEM
    require(sf)
    points <- st_as_sf(points, wkt="geom") %>% st_set_crs(4326)

(an alternative, potentially faster route would have been to leave the `wkb_geometry` column in, and use `st_as_sf` without the `wkt` argument.)

We can now scrape our dataset for the data we are looking for, e.g. all
bicycle parking spots (see
<https://wiki.openstreetmap.org/wiki/Tag:amenity%3Dbicycle_parking>.
Since `sf` data is stored in spatial data frames, we can easily create a
subset containing our desired points - e.g. using the `filter` function
from the `dplyr` package and `str_detect` from `stringr`:

    require(dplyr)
    require(stringr)
    #EXTRACTING ALL POINTS TAGGED 'BUS_STOP'
    bikepark <- points %>% filter(str_detect(other_tags, "bicycle_parking"))

Additionally to all bike parking spots, we also want to include all
explicitly marked bicycle routes, as found in the `lines` data. These
can be extracted from OSM relation data via the `cycleway` tag:
<https://wiki.openstreetmap.org/wiki/Key:cycleway>

We can contrast cycleways from the regular road network by also
selecting the most common road types (see
<https://wiki.openstreetmap.org/wiki/Key:highway>). Note that after our
final `PostgreSQL` query, we close the connection using the
`dbDisconnect` command in order to not overload the driver.

    #LOAD RELATION DATA
    lines <- dbGetQuery(connection, "SELECT * , ST_AsText(wkb_geometry) AS geom from lines")
    lines$wkb_geometry <- NULL
    dbDisconnect(connection)

    ## [1] TRUE

    #SET CRS
    lines <- st_as_sf(lines, wkt="geom") %>% st_set_crs(4326)
    #SUBSET CYCLEWAYS
    cycleways <- lines %>% filter(highway=="cycleway")
    #SUBSET OTHER STREETS
    streets <- lines %>% filter(highway=="motorway" |
                                highway=="trunk" |
                                highway=="primary" |
                                highway=="secondary" |
                                highway=="tertiary")

Having created subsets for bicycle parking spots, cycleways and regular
roads. We finally plot our data using `ggplot2` and the `geom_sf`
function:

    require(ggplot2)
    #PLOTTING ALL BUS STOPS
    ggplot(bikepark) +
      geom_sf(data=streets,aes(colour="lightgrey")) + #Requires development version of ggplot2: devtools::install_github("tidyverse/ggplot2")
      geom_sf(data=cycleways,aes(colour="turquoise")) +
      geom_sf(data=bikepark,aes(colour="turquoise4"),shape=".") + 
      coord_sf(crs = st_crs(bikepark)) +
      ggtitle("Biking infrastructure (parking + cycleways) in London") +
      scale_colour_manual("",values = c("lightgrey","turquoise","turquoise4"),labels=c("Other Roads","Cycleways","Bike Parking")) +
      theme_void() +
      theme(legend.position="bottom") 

![](https://konstantinklemmer.github.io/images/blog/OSM_in_R/bikemap.png)
