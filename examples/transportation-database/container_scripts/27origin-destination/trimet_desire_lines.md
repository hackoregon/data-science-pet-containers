TriMet Service Area Desire Lines
================
M. Edward (Ed) Borasky
2018-06-06

## Introduction

As part of the Hack Oregon 2018 season, TriMet gave the Transportation
Systems team a dataset summarizing ridership metrics by service stop,
totaled over three-month quarters. This dataset covers March 2001
through November 2017, and includes breakdowns for weekday, Saturday and
Sunday service.

To provide context for the weekday service, which includes commuters, we
analyzed another dataset, the US Census Bureau’s Longitudinal
Employer-Household Dynamics (LEHD) LEHD Origin-Destination Employment
Statistics (LODES) data (“LEHD Origin-Destination Employment Statistics
(Lodes),” n.d.). This dataset covers the years 2002 through 2015.

The LODES dataset provides job counts by the workers’ home and work
census blocks, where the blocks are defined by the 2010 decennial
census. We use the `lodes` package {Rudis (2017)\] to acquire the LODES
data and `stplanr` \[Lovelace2018a\] to compute the desire lines.

## Acquiring the LODES data

### Downloading the crosswalk file

First, we download the “crosswalk” file for Oregon. This file contains
the geographic information for the census
    blocks.

``` r
read_xwalk("or", download_dir = "~/Raw") -> or_xwalk
```

    ## Cached version of file found in [/home/znmeb/Raw/or_xwalk.csv.gz].
    ## Reading data from it...

``` r
as.character(or_xwalk$tabblk2010) -> or_xwalk$tabblk2010
```

### Filtering down to the TriMet service area

The TriMet service area is contained in three Oregon counties -
Clackamas, Multnomah and Washington. So we filter the crosswalk table
down to just those three counties.

``` r
or_xwalk %>% filter(
  ctyname == "Clackamas County, OR" |
    ctyname == "Multnomah County, OR" |
    ctyname == "Washington County, OR"
) -> or_xwalk
```

### Making the “zones” file

The process `stplanr` uses to compute the desire lines has two inputs,
the *flow* and the *zones* (Lovelace and Ellison 2018, vignette
“Introducing stplanr”). The `zones` data frame is a
SpatialPointsDataFrame as defined by the `sp` package (Pebesma and
Bivand 2005, @Bivand2013)

``` r
SpatialPointsDataFrame(
  coords = select(or_xwalk, blklondd, blklatdd),
    data = or_xwalk,
    proj4string = CRS("+init=epsg:4269")) -> zones
```

## Session info

``` r
devtools::session_info()
```

    ## Session info -------------------------------------------------------------

    ##  setting  value                       
    ##  version  R version 3.5.0 (2018-04-23)
    ##  system   x86_64, linux-gnu           
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_US.UTF-8                 
    ##  tz       America/Los_Angeles         
    ##  date     2018-06-06

    ## Packages -----------------------------------------------------------------

    ##  package      * version    date       source                              
    ##  assertthat     0.2.0      2017-04-11 CRAN (R 3.5.0)                      
    ##  backports      1.1.2      2017-12-13 CRAN (R 3.5.0)                      
    ##  base         * 3.5.0      2018-04-28 local                               
    ##  base64enc      0.1-3      2015-07-28 CRAN (R 3.5.0)                      
    ##  bindr          0.1.1      2018-03-13 CRAN (R 3.5.0)                      
    ##  bindrcpp     * 0.2.2      2018-03-29 CRAN (R 3.5.0)                      
    ##  broom          0.4.4      2018-03-29 CRAN (R 3.5.0)                      
    ##  cellranger     1.1.0      2016-07-27 CRAN (R 3.5.0)                      
    ##  class          7.3-14     2015-08-30 CRAN (R 3.5.0)                      
    ##  classInt       0.2-3      2018-04-16 CRAN (R 3.5.0)                      
    ##  cli            1.0.0      2017-11-05 CRAN (R 3.5.0)                      
    ##  codetools      0.2-15     2016-10-05 CRAN (R 3.5.0)                      
    ##  colorspace     1.3-2      2016-12-14 CRAN (R 3.5.0)                      
    ##  compiler       3.5.0      2018-04-28 local                               
    ##  crayon         1.3.4      2017-09-16 CRAN (R 3.5.0)                      
    ##  crosstalk      1.0.0      2016-12-21 CRAN (R 3.5.0)                      
    ##  curl           3.2        2018-03-28 CRAN (R 3.5.0)                      
    ##  datasets     * 3.5.0      2018-04-28 local                               
    ##  DBI            1.0.0      2018-05-02 CRAN (R 3.5.0)                      
    ##  devtools       1.13.5     2018-02-18 CRAN (R 3.5.0)                      
    ##  dichromat      2.0-0      2013-01-24 CRAN (R 3.5.0)                      
    ##  digest         0.6.15     2018-01-28 CRAN (R 3.5.0)                      
    ##  dplyr        * 0.7.5      2018-05-19 CRAN (R 3.5.0)                      
    ##  e1071          1.6-8      2017-02-02 CRAN (R 3.5.0)                      
    ##  evaluate       0.10.1     2017-06-24 CRAN (R 3.5.0)                      
    ##  forcats      * 0.3.0      2018-02-19 CRAN (R 3.5.0)                      
    ##  foreach        1.4.4      2017-12-12 CRAN (R 3.5.0)                      
    ##  foreign        0.8-70     2018-04-23 CRAN (R 3.5.0)                      
    ##  gdalUtils      2.0.1.14   2018-04-23 CRAN (R 3.5.0)                      
    ##  geosphere      1.5-7      2017-11-05 CRAN (R 3.5.0)                      
    ##  ggplot2      * 2.2.1.9000 2018-06-06 Github (tidyverse/ggplot2@4db5122)  
    ##  glue           1.2.0      2017-10-29 CRAN (R 3.5.0)                      
    ##  graphics     * 3.5.0      2018-04-28 local                               
    ##  grDevices    * 3.5.0      2018-04-28 local                               
    ##  grid           3.5.0      2018-04-28 local                               
    ##  gtable         0.2.0      2016-02-26 CRAN (R 3.5.0)                      
    ##  haven          1.1.1      2018-01-18 CRAN (R 3.5.0)                      
    ##  hms            0.4.2      2018-03-10 CRAN (R 3.5.0)                      
    ##  htmltools      0.3.6      2017-04-28 CRAN (R 3.5.0)                      
    ##  htmlwidgets    1.2        2018-04-19 CRAN (R 3.5.0)                      
    ##  httpuv         1.4.3      2018-05-10 CRAN (R 3.5.0)                      
    ##  httr           1.3.1      2017-08-20 CRAN (R 3.5.0)                      
    ##  igraph         1.2.1      2018-03-10 CRAN (R 3.5.0)                      
    ##  iterators      1.0.9      2017-12-12 CRAN (R 3.5.0)                      
    ##  jsonlite       1.5        2017-06-01 CRAN (R 3.5.0)                      
    ##  KernSmooth     2.23-15    2015-06-29 CRAN (R 3.5.0)                      
    ##  knitr          1.20       2018-02-20 CRAN (R 3.5.0)                      
    ##  later          0.7.2      2018-05-01 CRAN (R 3.5.0)                      
    ##  lattice        0.20-35    2017-03-25 CRAN (R 3.5.0)                      
    ##  lazyeval       0.2.1      2017-10-29 CRAN (R 3.5.0)                      
    ##  leaflet        2.0.1.9000 2018-06-06 Github (rstudio/leaflet@c3fd1c1)    
    ##  lodes        * 0.1.0      2018-06-06 Github (hrbrmstr/lodes@8cca008)     
    ##  lubridate      1.7.4      2018-04-11 CRAN (R 3.5.0)                      
    ##  magrittr       1.5        2014-11-22 CRAN (R 3.5.0)                      
    ##  maptools       0.9-2      2017-03-25 CRAN (R 3.5.0)                      
    ##  mapview        2.4.0      2018-04-28 CRAN (R 3.5.0)                      
    ##  memoise        1.1.0      2017-04-21 CRAN (R 3.5.0)                      
    ##  methods      * 3.5.0      2018-04-28 local                               
    ##  mime           0.5        2016-07-07 CRAN (R 3.5.0)                      
    ##  mnormt         1.5-5      2016-10-15 CRAN (R 3.5.0)                      
    ##  modelr         0.1.2      2018-05-11 CRAN (R 3.5.0)                      
    ##  munsell        0.4.3      2016-02-13 CRAN (R 3.5.0)                      
    ##  nlme           3.1-137    2018-04-07 CRAN (R 3.5.0)                      
    ##  openxlsx       4.1.0      2018-05-26 CRAN (R 3.5.0)                      
    ##  parallel       3.5.0      2018-04-28 local                               
    ##  pillar         1.2.3      2018-05-25 CRAN (R 3.5.0)                      
    ##  pkgconfig      2.0.1      2017-03-21 CRAN (R 3.5.0)                      
    ##  plyr           1.8.4      2016-06-08 CRAN (R 3.5.0)                      
    ##  png            0.1-7      2013-12-03 CRAN (R 3.5.0)                      
    ##  promises       1.0.1      2018-04-13 CRAN (R 3.5.0)                      
    ##  psych          1.8.4      2018-05-06 CRAN (R 3.5.0)                      
    ##  purrr        * 0.2.5      2018-05-29 cran (@0.2.5)                       
    ##  R.methodsS3    1.7.1      2016-02-16 CRAN (R 3.5.0)                      
    ##  R.oo           1.22.0     2018-04-22 CRAN (R 3.5.0)                      
    ##  R.utils        2.6.0      2017-11-05 CRAN (R 3.5.0)                      
    ##  R6             2.2.2      2017-06-17 CRAN (R 3.5.0)                      
    ##  raster         2.6-7      2017-11-13 CRAN (R 3.5.0)                      
    ##  RColorBrewer   1.1-2      2014-12-07 CRAN (R 3.5.0)                      
    ##  Rcpp           0.12.17    2018-05-18 CRAN (R 3.5.0)                      
    ##  readr        * 1.1.1      2017-05-16 CRAN (R 3.5.0)                      
    ##  readxl         1.1.0      2018-04-20 CRAN (R 3.5.0)                      
    ##  reshape2       1.4.3      2017-12-11 CRAN (R 3.5.0)                      
    ##  rgdal          1.3-1      2018-06-03 cran (@1.3-1)                       
    ##  rgeos          0.3-27     2018-06-01 cran (@0.3-27)                      
    ##  rlang          0.2.1      2018-05-30 CRAN (R 3.5.0)                      
    ##  rmarkdown      1.9        2018-03-01 CRAN (R 3.5.0)                      
    ##  rprojroot      1.3-2      2018-01-03 CRAN (R 3.5.0)                      
    ##  rstudioapi     0.7        2017-09-07 CRAN (R 3.5.0)                      
    ##  rvest          0.3.2      2016-06-17 CRAN (R 3.5.0)                      
    ##  satellite      1.0.1      2017-10-18 CRAN (R 3.5.0)                      
    ##  scales         0.5.0      2017-08-24 CRAN (R 3.5.0)                      
    ##  sf             0.6-3      2018-05-17 CRAN (R 3.5.0)                      
    ##  shiny          1.1.0      2018-05-17 CRAN (R 3.5.0)                      
    ##  sp           * 1.3-1      2018-06-05 CRAN (R 3.5.0)                      
    ##  spData         0.2.8.9    2018-06-06 Github (nowosad/spData@7b53933)     
    ##  spDataLarge    0.2.6.5    2018-06-06 Github (nowosad/spDataLarge@bc058ad)
    ##  stats        * 3.5.0      2018-04-28 local                               
    ##  stats4         3.5.0      2018-04-28 local                               
    ##  stplanr      * 0.2.5      2018-06-02 CRAN (R 3.5.0)                      
    ##  stringi        1.2.2      2018-05-02 CRAN (R 3.5.0)                      
    ##  stringr      * 1.3.1      2018-05-10 CRAN (R 3.5.0)                      
    ##  tibble       * 1.4.2      2018-01-22 CRAN (R 3.5.0)                      
    ##  tidyr        * 0.8.1      2018-05-18 CRAN (R 3.5.0)                      
    ##  tidyselect     0.2.4      2018-02-26 CRAN (R 3.5.0)                      
    ##  tidyverse    * 1.2.1      2017-11-14 CRAN (R 3.5.0)                      
    ##  tmap         * 2.0        2018-06-06 Github (mtennekes/tmap@2185f1d)     
    ##  tmaptools      2.0        2018-06-06 Github (mtennekes/tmaptools@8164261)
    ##  tools          3.5.0      2018-04-28 local                               
    ##  udunits2       0.13       2016-11-17 CRAN (R 3.5.0)                      
    ##  units          0.5-1      2018-01-08 CRAN (R 3.5.0)                      
    ##  utils        * 3.5.0      2018-04-28 local                               
    ##  viridisLite    0.3.0      2018-02-01 CRAN (R 3.5.0)                      
    ##  webshot        0.5.0      2017-11-29 CRAN (R 3.5.0)                      
    ##  withr          2.1.2      2018-03-15 CRAN (R 3.5.0)                      
    ##  XML            3.98-1.11  2018-04-16 CRAN (R 3.5.0)                      
    ##  xml2           1.2.0      2018-01-24 CRAN (R 3.5.0)                      
    ##  xtable         1.8-2      2016-02-05 CRAN (R 3.5.0)                      
    ##  yaml           2.1.19     2018-05-01 CRAN (R 3.5.0)                      
    ##  zip            1.0.0      2017-04-25 CRAN (R 3.5.0)

## References

<div id="refs" class="references">

<div id="ref-Bivand2013">

Bivand, Roger S., Edzer Pebesma, and Virgilio Gomez-Rubio. 2013.
*Applied Spatial Data Analysis with R, Second Edition*. Springer, NY.
<http://www.asdar-book.org/>.

</div>

<div id="ref-LODES2018">

“LEHD Origin-Destination Employment Statistics (Lodes).” n.d.
<https://lehd.ces.census.gov/data/#lodes>.

</div>

<div id="ref-Lovelace2018a">

Lovelace, Robin, and Richard Ellison. 2018. *Stplanr: Sustainable
Transport Planning*. <https://CRAN.R-project.org/package=stplanr>.

</div>

<div id="ref-Pebesma2005">

Pebesma, Edzer J., and Roger S. Bivand. 2005. “Classes and Methods for
Spatial Data in R.” *R News* 5 (2): 9–13.
<https://CRAN.R-project.org/doc/Rnews/>.

</div>

<div id="ref-Rudis2017">

Rudis, Bob. 2017. *Lodes: Retrieve Data from Lehd Origin-Destination
Employment Statistics Server*. <http://github.com/hrbrmstr/lodes>.

</div>

</div>
