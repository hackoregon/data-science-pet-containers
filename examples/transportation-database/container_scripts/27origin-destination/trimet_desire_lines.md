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
or_xwalk <- read_xwalk("or", download_dir = "~/Raw")
```

    ## Cached version of file found in [/home/znmeb/Raw/or_xwalk.csv.gz].
    ## Reading data from it...

``` r
or_xwalk$tabblk2010 <- as.character(or_xwalk$tabblk2010) 
```

### Filtering down to the TriMet service area

The TriMet service area is contained in three Oregon counties -
Clackamas, Multnomah and Washington. So we filter the crosswalk table
down to just those three counties.

``` r
or_xwalk <- or_xwalk %>% filter(
  ctyname == "Clackamas County, OR" |
    ctyname == "Multnomah County, OR" |
    ctyname == "Washington County, OR"
)
```

### Acquring the origin-destination files

``` r
or_od_main_JT00 <- tibble() 
for (year in 2002:2015) {
  or_od_main_JT00 <- or_od_main_JT00 %>% bind_rows(
    read_lodes("or", "od", "main", "JT00", year, download_dir = "~/Raw") %>% 
      mutate(year = year)
  )
  gc(full = TRUE, verbose = TRUE)
}
```

    ## Cached version of file found in [/home/znmeb/Raw/or_od_main_JT00_2002.csv.gz].
    ## Reading data from it...

    ## Cached version of file found in [/home/znmeb/Raw/or_od_main_JT00_2003.csv.gz].
    ## Reading data from it...

    ## Cached version of file found in [/home/znmeb/Raw/or_od_main_JT00_2004.csv.gz].
    ## Reading data from it...

    ## Cached version of file found in [/home/znmeb/Raw/or_od_main_JT00_2005.csv.gz].
    ## Reading data from it...

    ## Cached version of file found in [/home/znmeb/Raw/or_od_main_JT00_2006.csv.gz].
    ## Reading data from it...

    ## Cached version of file found in [/home/znmeb/Raw/or_od_main_JT00_2007.csv.gz].
    ## Reading data from it...

    ## Cached version of file found in [/home/znmeb/Raw/or_od_main_JT00_2008.csv.gz].
    ## Reading data from it...

    ## Cached version of file found in [/home/znmeb/Raw/or_od_main_JT00_2009.csv.gz].
    ## Reading data from it...

    ## Cached version of file found in [/home/znmeb/Raw/or_od_main_JT00_2010.csv.gz].
    ## Reading data from it...

    ## Cached version of file found in [/home/znmeb/Raw/or_od_main_JT00_2011.csv.gz].
    ## Reading data from it...

    ## Cached version of file found in [/home/znmeb/Raw/or_od_main_JT00_2012.csv.gz].
    ## Reading data from it...

    ## Cached version of file found in [/home/znmeb/Raw/or_od_main_JT00_2013.csv.gz].
    ## Reading data from it...

    ## Cached version of file found in [/home/znmeb/Raw/or_od_main_JT00_2014.csv.gz].
    ## Reading data from it...

    ## Warning in rbind(names(probs), probs_f): number of columns of result is not
    ## a multiple of vector length (arg 2)

    ## Warning: 1 parsing failure.
    ## row # A tibble: 1 x 5 col       row col   expected   actual     file                                 expected     <int> <chr> <chr>      <chr>      <chr>                                actual 1 1318571 <NA>  13 columns 11 columns '/home/znmeb/Raw/or_od_main_JT00_20… file # A tibble: 1 x 5

    ## Cached version of file found in [/home/znmeb/Raw/or_od_main_JT00_2015.csv.gz].
    ## Reading data from it...

``` r
or_od_main_JT00$w_geocode <- as.character(or_od_main_JT00$w_geocode)
or_od_main_JT00$h_geocode <- as.character(or_od_main_JT00$h_geocode)
```

### Filter down to the TriMet service area

``` r
or_od_main_JT00 <- or_od_main_JT00 %>% 
  semi_join(or_xwalk, by = c("w_geocode" = "tabblk2010")) %>% 
  semi_join(or_xwalk, by = c("h_geocode" = "tabblk2010"))
```

## Computing the desire lines

### Computing the flow

``` r
flow <- or_od_main_JT00 %>% filter(year == 2015) %>% 
  select(w_geocode, h_geocode, S000) %>% 
  arrange(desc(S000)) %>% top_n(100, S000)
```

### Making the “zones” file

The process `stplanr` uses to compute the desire lines has two inputs,
the *flow* and the *zones* (Lovelace and Ellison 2018, vignette
“Introducing stplanr”). The `zones` data frame is a
SpatialPointsDataFrame as defined by the `sp` package (Pebesma and
Bivand 2005, @Bivand2013)

``` r
zones <- SpatialPointsDataFrame(
  coords = select(or_xwalk, blklondd, blklatdd),
    data = select(or_xwalk, tabblk2010, blklondd, blklatdd),
    proj4string = CRS("+init=epsg:4269"))
```

### Make the desire lines

``` r
desire_lines <- od2line(flow, zones)
tmap_mode("view")
```

    ## tmap mode set to interactive viewing

``` r
qtm(desire_lines)
```

    ## PhantomJS not found. You can install it with webshot::install_phantomjs(). If it is installed, please make sure the phantomjs executable can be found via the PATH variable.

<!--html_preserve-->

<div id="htmlwidget-e793f306771ebc62b43f" class="leaflet html-widget" style="width:672px;height:480px;">

</div>

<script type="application/json" data-for="htmlwidget-e793f306771ebc62b43f">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addProviderTiles","args":["CartoDB.Positron",null,"CartoDB.Positron",{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false}]},{"method":"addProviderTiles","args":["OpenStreetMap",null,"OpenStreetMap",{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false}]},{"method":"addProviderTiles","args":["Esri.WorldTopoMap",null,"Esri.WorldTopoMap",{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false}]},{"method":"addPolylines","args":[[[[{"lng":[-122.9056815,-122.9195569],"lat":[45.5449634,45.5317298]}]],[[{"lng":[-122.9056815,-122.8721257],"lat":[45.5449634,45.5369492]}]],[[{"lng":[-122.9056815,-122.8879425],"lat":[45.5449634,45.5399563]}]],[[{"lng":[-122.9056815,-122.9180011],"lat":[45.5449634,45.5264293]}]],[[{"lng":[-122.9625461,-122.8721257],"lat":[45.5444992,45.5369492]}]],[[{"lng":[-122.9056815,-122.8151828],"lat":[45.5449634,45.5598365]}]],[[{"lng":[-122.6831206,-122.6702931],"lat":[45.4986898,45.4960667]}]],[[{"lng":[-122.6831206,-122.6905456],"lat":[45.4986898,45.5001195]}]],[[{"lng":[-122.9625461,-122.9195569],"lat":[45.5444992,45.5317298]}]],[[{"lng":[-122.9625461,-122.8879425],"lat":[45.5444992,45.5399563]}]],[[{"lng":[-122.9625461,-122.9740323],"lat":[45.5444992,45.5470331]}]],[[{"lng":[-122.9056815,-122.9740323],"lat":[45.5449634,45.5470331]}]],[[{"lng":[-122.9625461,-122.9180011],"lat":[45.5444992,45.5264293]}]],[[{"lng":[-122.9056815,-122.8453079],"lat":[45.5449634,45.5541435]}]],[[{"lng":[-122.6831206,-122.6713653],"lat":[45.4986898,45.4957174]}]],[[{"lng":[-122.6975373,-122.8445076],"lat":[45.5619582,45.5211617]}]],[[{"lng":[-122.8221055,-122.7519034],"lat":[45.5050981,45.5116666]}]],[[{"lng":[-122.9056815,-122.8491],"lat":[45.5449634,45.5605935]}]],[[{"lng":[-122.6831206,-122.6702582],"lat":[45.4986898,45.4967408]}]],[[{"lng":[-122.8221055,-122.8391125],"lat":[45.5050981,45.4406285]}]],[[{"lng":[-122.9056815,-122.8815615],"lat":[45.5449634,45.5419441]}]],[[{"lng":[-122.8221055,-122.8035745],"lat":[45.5050981,45.5348006]}]],[[{"lng":[-122.9625461,-122.8151828],"lat":[45.5444992,45.5598365]}]],[[{"lng":[-122.6831206,-122.7519034],"lat":[45.4986898,45.5116666]}]],[[{"lng":[-122.6831206,-122.6793748],"lat":[45.4986898,45.4780426]}]],[[{"lng":[-122.9625461,-122.9903993],"lat":[45.5444992,45.5413007]}]],[[{"lng":[-122.7318619,-122.7277801],"lat":[45.5727866,45.5698609]}]],[[{"lng":[-122.9056815,-122.865125],"lat":[45.5449634,45.5598564]}]],[[{"lng":[-122.5742444,-122.5718855],"lat":[45.4358367,45.4421942]}]],[[{"lng":[-122.7656491,-122.7556702],"lat":[45.3212358,45.3298045]}]],[[{"lng":[-122.6831206,-122.6915297],"lat":[45.4986898,45.5028058]}]],[[{"lng":[-122.6831206,-122.6773052],"lat":[45.4986898,45.4799454]}]],[[{"lng":[-122.8221055,-122.8320966],"lat":[45.5050981,45.4999402]}]],[[{"lng":[-122.9056815,-122.8016925],"lat":[45.5449634,45.5411628]}]],[[{"lng":[-122.9056815,-122.91096],"lat":[45.5449634,45.5347508]}]],[[{"lng":[-122.9625461,-122.8491],"lat":[45.5444992,45.5605935]}]],[[{"lng":[-122.8221055,-122.7670047],"lat":[45.5050981,45.5278508]}]],[[{"lng":[-122.9056815,-122.7670047],"lat":[45.5449634,45.5278508]}]],[[{"lng":[-122.9056815,-122.9122288],"lat":[45.5449634,45.5234683]}]],[[{"lng":[-122.9056815,-122.9274986],"lat":[45.5449634,45.5220589]}]],[[{"lng":[-122.9056815,-122.9903993],"lat":[45.5449634,45.5413007]}]],[[{"lng":[-122.9056815,-122.9286653],"lat":[45.5449634,45.539938]}]],[[{"lng":[-122.9625461,-122.8815615],"lat":[45.5444992,45.5419441]}]],[[{"lng":[-122.6831206,-122.6801169],"lat":[45.4986898,45.5087279]}]],[[{"lng":[-122.8221055,-122.859072],"lat":[45.5050981,45.5071733]}]],[[{"lng":[-122.9056815,-122.8620413],"lat":[45.5449634,45.5484185]}]],[[{"lng":[-122.9056815,-122.9356881],"lat":[45.5449634,45.5356186]}]],[[{"lng":[-122.9625461,-122.9286653],"lat":[45.5444992,45.539938]}]],[[{"lng":[-122.8221055,-122.8151828],"lat":[45.5050981,45.5598365]}]],[[{"lng":[-122.8221055,-122.8721257],"lat":[45.5050981,45.5369492]}]],[[{"lng":[-122.8221055,-122.8751689],"lat":[45.5050981,45.4709505]}]],[[{"lng":[-122.9056815,-122.7948294],"lat":[45.5449634,45.5276625]}]],[[{"lng":[-122.9056815,-122.8854883],"lat":[45.5449634,45.5398258]}]],[[{"lng":[-122.9056815,-122.8391125],"lat":[45.5449634,45.4406285]}]],[[{"lng":[-122.9625461,-122.8583663],"lat":[45.5444992,45.5613272]}]],[[{"lng":[-122.9625461,-122.865125],"lat":[45.5444992,45.5598564]}]],[[{"lng":[-122.6975373,-122.8449243],"lat":[45.5619582,45.5150484]}]],[[{"lng":[-122.6831206,-122.8721257],"lat":[45.4986898,45.5369492]}]],[[{"lng":[-122.7712121,-122.7519034],"lat":[45.5095023,45.5116666]}]],[[{"lng":[-122.8221055,-122.7668336],"lat":[45.5050981,45.5384793]}]],[[{"lng":[-122.8221055,-122.9180011],"lat":[45.5050981,45.5264293]}]],[[{"lng":[-122.9056815,-122.8583663],"lat":[45.5449634,45.5613272]}]],[[{"lng":[-122.9056815,-122.8751689],"lat":[45.5449634,45.4709505]}]],[[{"lng":[-122.9625461,-122.9099607],"lat":[45.5444992,45.5212151]}]],[[{"lng":[-122.6831206,-122.7015974],"lat":[45.4986898,45.5014025]}]],[[{"lng":[-122.6831206,-122.7108446],"lat":[45.4986898,45.4418771]}]],[[{"lng":[-122.6831206,-122.7668336],"lat":[45.4986898,45.5384793]}]],[[{"lng":[-122.8221055,-122.8200353],"lat":[45.5050981,45.5347945]}]],[[{"lng":[-122.8221055,-122.8453079],"lat":[45.5050981,45.5541435]}]],[[{"lng":[-122.9056815,-122.8746105],"lat":[45.5449634,45.5529252]}]],[[{"lng":[-122.9056815,-122.8035745],"lat":[45.5449634,45.5348006]}]],[[{"lng":[-122.9056815,-122.8846852],"lat":[45.5449634,45.5386411]}]],[[{"lng":[-122.9056815,-122.9848047],"lat":[45.5449634,45.5332464]}]],[[{"lng":[-122.9625461,-122.8620413],"lat":[45.5444992,45.5484185]}]],[[{"lng":[-122.8221055,-122.7948294],"lat":[45.5050981,45.5276625]}]],[[{"lng":[-122.8221055,-122.8023157],"lat":[45.5050981,45.5456911]}]],[[{"lng":[-122.9056815,-122.8023157],"lat":[45.5449634,45.5456911]}]],[[{"lng":[-122.9056815,-122.8075965],"lat":[45.5449634,45.5537362]}]],[[{"lng":[-122.9056815,-122.8770878],"lat":[45.5449634,45.540881]}]],[[{"lng":[-122.9056815,-122.9062875],"lat":[45.5449634,45.537675]}]],[[{"lng":[-122.9625461,-122.9356881],"lat":[45.5444992,45.5356186]}]],[[{"lng":[-122.6831206,-122.7164354],"lat":[45.4986898,45.4237517]}]],[[{"lng":[-122.6831206,-122.6807749],"lat":[45.4986898,45.5071986]}]],[[{"lng":[-122.6831206,-122.6727443],"lat":[45.4986898,45.4719672]}]],[[{"lng":[-122.6831206,-122.7069962],"lat":[45.4986898,45.4504271]}]],[[{"lng":[-122.6831206,-122.7136221],"lat":[45.4986898,45.4822525]}]],[[{"lng":[-122.8221055,-122.8491],"lat":[45.5050981,45.5605935]}]],[[{"lng":[-122.9056815,-122.8933131],"lat":[45.5449634,45.5246758]}]],[[{"lng":[-122.9056815,-122.8644558],"lat":[45.5449634,45.524731]}]],[[{"lng":[-122.9056815,-122.8445076],"lat":[45.5449634,45.5211617]}]],[[{"lng":[-122.9056815,-122.9078188],"lat":[45.5449634,45.5372499]}]],[[{"lng":[-122.9625461,-122.8933131],"lat":[45.5444992,45.5246758]}]],[[{"lng":[-122.9625461,-122.91096],"lat":[45.5444992,45.5347508]}]],[[{"lng":[-122.9625461,-122.9680019],"lat":[45.5444992,45.5438452]}]],[[{"lng":[-122.6831206,-122.6874711],"lat":[45.4986898,45.5114933]}]],[[{"lng":[-122.6831206,-122.6844725],"lat":[45.4986898,45.5095174]}]],[[{"lng":[-122.6831206,-122.6882963],"lat":[45.4986898,45.5085684]}]],[[{"lng":[-122.8221055,-122.6839507],"lat":[45.5050981,45.5311244]}]],[[{"lng":[-122.8221055,-122.8449243],"lat":[45.5050981,45.5150484]}]],[[{"lng":[-122.9056815,-122.7668336],"lat":[45.5449634,45.5384793]}]],[[{"lng":[-122.9056815,-122.9680019],"lat":[45.5449634,45.5438452]}]],[[{"lng":[-122.9056815,-122.9775239],"lat":[45.5449634,45.5412719]}]],[[{"lng":[-122.9625461,-122.8453079],"lat":[45.5444992,45.5541435]}]],[[{"lng":[-122.9625461,-122.9775239],"lat":[45.5444992,45.5412719]}]]],1,"desire_lines",{"interactive":true,"className":"","stroke":true,"color":["#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000"],"weight":[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],"opacity":[0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7],"fill":false,"fillColor":["#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000","#FF0000"],"fillOpacity":0.2,"dashArray":"none","smoothFactor":1,"noClip":false},["<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326071061<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>75<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316162001<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>72<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316173006<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>59<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670324082006<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>55<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316162001<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>52<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315133001<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>49<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510059001002<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>48<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510058002016<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>44<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326071061<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>44<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316173006<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>42<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326091003<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>38<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326091003<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>37<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670324082006<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>37<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315143002<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>36<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510059001004<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>35<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510035013010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316111024<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>34<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670301014001<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>33<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315142005<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>32<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510059001007<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>31<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670318131002<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>31<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316172004<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>31<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315085004<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>29<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315133001<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>29<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670301014001<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>28<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510059004025<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>27<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326034000<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>26<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510040021030<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510040021032<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>25<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315091019<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>25<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410050222013004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410050222012011<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>24<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410050244001011<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410050244001001<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>24<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510058002011<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>24<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510059003010<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>24<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670314022009<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>24<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315082007<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>24<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326071032<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>24<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315142005<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>24<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670301022018<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>23<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670301022018<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>23<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670324081017<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>23<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670324082023<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>23<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326034000<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>23<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326081012<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>23<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316172004<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>23<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510057002026<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>22<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316121008<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>22<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315111003<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>22<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326081028<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>22<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326081012<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>22<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315133001<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>21<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316162001<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>21<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670318042002<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>21<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315081003<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>21<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316171000<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>21<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670318131002<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>21<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315091017<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>21<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315091019<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>21<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510035013010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316112017<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>20<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316162001<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>20<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670301013019<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670301014001<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>20<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510070004031<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>20<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670324082006<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>20<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315091017<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>20<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670318042002<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>20<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670324081013<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>20<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510058004000<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>19<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510064022007<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>19<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510070004031<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>19<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315071013<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>19<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315143002<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>19<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315041000<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>19<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315085004<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>19<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316171002<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>19<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326033000<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>19<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315111003<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>19<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315081003<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>18<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315084006<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>18<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315084006<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>18<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315131000<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>18<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316172001<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>18<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326071024<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>18<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326081028<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>18<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410050203033008<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>17<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510057001020<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>17<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510059002018<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>17<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510064021019<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>17<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510067021001<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>17<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315142005<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>17<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316094011<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>17<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316104003<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>17<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316111024<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>17<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326071023<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>17<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316094011<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>17<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326071032<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>17<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326091017<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>17<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510056003006<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>16<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510056003018<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>16<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410510058002014<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510058001002<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>16<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510050001065<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>16<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670314043004<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670316112017<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>16<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410510070004031<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>16<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326091017<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>16<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326071010<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326101014<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>16<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670315143002<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>16<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">w_geocode<\/td><td>410670326091000<\/td><\/tr><tr><td style=\"color: #888888;\">h_geocode<\/td><td>410670326101014<\/td><\/tr><tr><td style=\"color: #888888;\">S000<\/td><td>16<\/td><\/tr><\/table><\/div>"],{"maxWidth":4140,"minWidth":100,"autoPan":true,"keepInView":false,"closeButton":true,"className":""},null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addLayersControl","args":[["CartoDB.Positron","OpenStreetMap","Esri.WorldTopoMap"],"desire_lines",{"collapsed":true,"autoZIndex":true,"position":"topleft"}]}],"limits":{"lat":[45.3212358,45.5727866],"lng":[-122.9903993,-122.5718855]},"fitBounds":[45.3212358,-122.9903993,45.5727866,-122.5718855,[]]},"evals":[],"jsHooks":[]}</script>

<!--/html_preserve-->

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
    ##  date     2018-06-07

    ## Packages -----------------------------------------------------------------

    ##  package      * version   date       source                         
    ##  assertthat     0.2.0     2017-04-11 CRAN (R 3.5.0)                 
    ##  backports      1.1.2     2017-12-13 CRAN (R 3.5.0)                 
    ##  base         * 3.5.0     2018-04-28 local                          
    ##  base64enc      0.1-3     2015-07-28 CRAN (R 3.5.0)                 
    ##  bindr          0.1.1     2018-03-13 CRAN (R 3.5.0)                 
    ##  bindrcpp     * 0.2.2     2018-03-29 CRAN (R 3.5.0)                 
    ##  bitops         1.0-6     2013-08-17 CRAN (R 3.5.0)                 
    ##  boot           1.3-20    2017-07-30 CRAN (R 3.5.0)                 
    ##  broom          0.4.4     2018-03-29 CRAN (R 3.5.0)                 
    ##  cellranger     1.1.0     2016-07-27 CRAN (R 3.5.0)                 
    ##  class          7.3-14    2015-08-30 CRAN (R 3.5.0)                 
    ##  classInt       0.2-3     2018-04-16 CRAN (R 3.5.0)                 
    ##  cli            1.0.0     2017-11-05 CRAN (R 3.5.0)                 
    ##  coda           0.19-1    2016-12-08 CRAN (R 3.5.0)                 
    ##  codetools      0.2-15    2016-10-05 CRAN (R 3.5.0)                 
    ##  colorspace     1.3-2     2016-12-14 CRAN (R 3.5.0)                 
    ##  compiler       3.5.0     2018-04-28 local                          
    ##  crayon         1.3.4     2017-09-16 CRAN (R 3.5.0)                 
    ##  crosstalk      1.0.0     2016-12-21 CRAN (R 3.5.0)                 
    ##  curl           3.2       2018-03-28 CRAN (R 3.5.0)                 
    ##  datasets     * 3.5.0     2018-04-28 local                          
    ##  DBI            1.0.0     2018-05-02 CRAN (R 3.5.0)                 
    ##  deldir         0.1-15    2018-04-01 CRAN (R 3.5.0)                 
    ##  devtools       1.13.5    2018-02-18 CRAN (R 3.5.0)                 
    ##  dichromat      2.0-0     2013-01-24 CRAN (R 3.5.0)                 
    ##  digest         0.6.15    2018-01-28 CRAN (R 3.5.0)                 
    ##  dplyr        * 0.7.5     2018-05-19 CRAN (R 3.5.0)                 
    ##  e1071          1.6-8     2017-02-02 CRAN (R 3.5.0)                 
    ##  evaluate       0.10.1    2017-06-24 CRAN (R 3.5.0)                 
    ##  expm           0.999-2   2017-03-29 CRAN (R 3.5.0)                 
    ##  forcats      * 0.3.0     2018-02-19 CRAN (R 3.5.0)                 
    ##  foreach        1.4.4     2017-12-12 CRAN (R 3.5.0)                 
    ##  foreign        0.8-70    2018-04-23 CRAN (R 3.5.0)                 
    ##  gdalUtils      2.0.1.14  2018-04-23 CRAN (R 3.5.0)                 
    ##  gdata          2.18.0    2017-06-06 CRAN (R 3.5.0)                 
    ##  geojsonlint    0.2.0     2016-11-03 CRAN (R 3.5.0)                 
    ##  geosphere      1.5-7     2017-11-05 CRAN (R 3.5.0)                 
    ##  ggplot2      * 2.2.1     2016-12-30 CRAN (R 3.5.0)                 
    ##  glue           1.2.0     2017-10-29 CRAN (R 3.5.0)                 
    ##  gmodels        2.16.2    2015-07-22 CRAN (R 3.5.0)                 
    ##  graphics     * 3.5.0     2018-04-28 local                          
    ##  grDevices    * 3.5.0     2018-04-28 local                          
    ##  grid           3.5.0     2018-04-28 local                          
    ##  gtable         0.2.0     2016-02-26 CRAN (R 3.5.0)                 
    ##  gtools         3.5.0     2015-05-29 CRAN (R 3.5.0)                 
    ##  haven          1.1.1     2018-01-18 CRAN (R 3.5.0)                 
    ##  hms            0.4.2     2018-03-10 CRAN (R 3.5.0)                 
    ##  htmltools      0.3.6     2017-04-28 CRAN (R 3.5.0)                 
    ##  htmlwidgets    1.2       2018-04-19 CRAN (R 3.5.0)                 
    ##  httpuv         1.4.3     2018-05-10 CRAN (R 3.5.0)                 
    ##  httr           1.3.1     2017-08-20 CRAN (R 3.5.0)                 
    ##  igraph         1.2.1     2018-03-10 CRAN (R 3.5.0)                 
    ##  iterators      1.0.9     2017-12-12 CRAN (R 3.5.0)                 
    ##  jsonlite       1.5       2017-06-01 CRAN (R 3.5.0)                 
    ##  jsonvalidate   1.0.0     2016-06-13 CRAN (R 3.5.0)                 
    ##  KernSmooth     2.23-15   2015-06-29 CRAN (R 3.5.0)                 
    ##  knitr          1.20      2018-02-20 CRAN (R 3.5.0)                 
    ##  later          0.7.2     2018-05-01 CRAN (R 3.5.0)                 
    ##  lattice        0.20-35   2017-03-25 CRAN (R 3.5.0)                 
    ##  lazyeval       0.2.1     2017-10-29 CRAN (R 3.5.0)                 
    ##  leaflet        2.0.1     2018-06-04 CRAN (R 3.5.0)                 
    ##  LearnBayes     2.15.1    2018-03-18 CRAN (R 3.5.0)                 
    ##  lodes        * 0.1.0     2018-06-07 Github (hrbrmstr/lodes@8cca008)
    ##  lubridate      1.7.4     2018-04-11 CRAN (R 3.5.0)                 
    ##  magrittr       1.5       2014-11-22 CRAN (R 3.5.0)                 
    ##  maptools       0.9-2     2017-03-25 CRAN (R 3.5.0)                 
    ##  mapview        2.4.0     2018-04-28 CRAN (R 3.5.0)                 
    ##  MASS           7.3-50    2018-04-30 CRAN (R 3.5.0)                 
    ##  Matrix         1.2-14    2018-04-09 CRAN (R 3.5.0)                 
    ##  memoise        1.1.0     2017-04-21 CRAN (R 3.5.0)                 
    ##  methods      * 3.5.0     2018-04-28 local                          
    ##  mime           0.5       2016-07-07 CRAN (R 3.5.0)                 
    ##  mnormt         1.5-5     2016-10-15 CRAN (R 3.5.0)                 
    ##  modelr         0.1.2     2018-05-11 CRAN (R 3.5.0)                 
    ##  munsell        0.4.3     2016-02-13 CRAN (R 3.5.0)                 
    ##  nlme           3.1-137   2018-04-07 CRAN (R 3.5.0)                 
    ##  openxlsx       4.1.0     2018-05-26 CRAN (R 3.5.0)                 
    ##  osmar          1.1-7     2013-11-21 CRAN (R 3.5.0)                 
    ##  parallel       3.5.0     2018-04-28 local                          
    ##  pillar         1.2.3     2018-05-25 CRAN (R 3.5.0)                 
    ##  pkgconfig      2.0.1     2017-03-21 CRAN (R 3.5.0)                 
    ##  plyr           1.8.4     2016-06-08 CRAN (R 3.5.0)                 
    ##  png            0.1-7     2013-12-03 CRAN (R 3.5.0)                 
    ##  promises       1.0.1     2018-04-13 CRAN (R 3.5.0)                 
    ##  psych          1.8.4     2018-05-06 CRAN (R 3.5.0)                 
    ##  purrr        * 0.2.5     2018-05-29 CRAN (R 3.5.0)                 
    ##  R.methodsS3    1.7.1     2016-02-16 CRAN (R 3.5.0)                 
    ##  R.oo           1.22.0    2018-04-22 CRAN (R 3.5.0)                 
    ##  R.utils        2.6.0     2017-11-05 CRAN (R 3.5.0)                 
    ##  R6             2.2.2     2017-06-17 CRAN (R 3.5.0)                 
    ##  raster         2.6-7     2017-11-13 CRAN (R 3.5.0)                 
    ##  RColorBrewer   1.1-2     2014-12-07 CRAN (R 3.5.0)                 
    ##  Rcpp           0.12.17   2018-05-18 CRAN (R 3.5.0)                 
    ##  RCurl          1.95-4.10 2018-01-04 CRAN (R 3.5.0)                 
    ##  readr        * 1.1.1     2017-05-16 CRAN (R 3.5.0)                 
    ##  readxl         1.1.0     2018-04-20 CRAN (R 3.5.0)                 
    ##  reshape2       1.4.3     2017-12-11 CRAN (R 3.5.0)                 
    ##  rgdal          1.3-1     2018-06-03 CRAN (R 3.5.0)                 
    ##  rgeos          0.3-27    2018-06-01 CRAN (R 3.5.0)                 
    ##  rlang          0.2.1     2018-05-30 CRAN (R 3.5.0)                 
    ##  rmapshaper     0.4.0     2018-04-03 CRAN (R 3.5.0)                 
    ##  rmarkdown      1.9       2018-03-01 CRAN (R 3.5.0)                 
    ##  rprojroot      1.3-2     2018-01-03 CRAN (R 3.5.0)                 
    ##  rstudioapi     0.7       2017-09-07 CRAN (R 3.5.0)                 
    ##  rvest          0.3.2     2016-06-17 CRAN (R 3.5.0)                 
    ##  satellite      1.0.1     2017-10-18 CRAN (R 3.5.0)                 
    ##  scales         0.5.0     2017-08-24 CRAN (R 3.5.0)                 
    ##  sf             0.6-3     2018-05-17 CRAN (R 3.5.0)                 
    ##  shiny          1.1.0     2018-05-17 CRAN (R 3.5.0)                 
    ##  sp           * 1.3-1     2018-06-05 CRAN (R 3.5.0)                 
    ##  spData         0.2.8.3   2018-03-25 CRAN (R 3.5.0)                 
    ##  spdep          0.7-7     2018-04-03 CRAN (R 3.5.0)                 
    ##  splines        3.5.0     2018-04-28 local                          
    ##  stats        * 3.5.0     2018-04-28 local                          
    ##  stats4         3.5.0     2018-04-28 local                          
    ##  stplanr      * 0.2.5     2018-06-02 CRAN (R 3.5.0)                 
    ##  stringi        1.2.2     2018-05-02 CRAN (R 3.5.0)                 
    ##  stringr      * 1.3.1     2018-05-10 CRAN (R 3.5.0)                 
    ##  tibble       * 1.4.2     2018-01-22 CRAN (R 3.5.0)                 
    ##  tidyr        * 0.8.1     2018-05-18 CRAN (R 3.5.0)                 
    ##  tidyselect     0.2.4     2018-02-26 CRAN (R 3.5.0)                 
    ##  tidyverse    * 1.2.1     2017-11-14 CRAN (R 3.5.0)                 
    ##  tmap         * 1.11-2    2018-04-10 CRAN (R 3.5.0)                 
    ##  tmaptools      1.2-4     2018-04-10 CRAN (R 3.5.0)                 
    ##  tools          3.5.0     2018-04-28 local                          
    ##  udunits2       0.13      2016-11-17 CRAN (R 3.5.0)                 
    ##  units          0.5-1     2018-01-08 CRAN (R 3.5.0)                 
    ##  utf8           1.1.4     2018-05-24 CRAN (R 3.5.0)                 
    ##  utils        * 3.5.0     2018-04-28 local                          
    ##  V8             1.5       2017-04-25 CRAN (R 3.5.0)                 
    ##  viridisLite    0.3.0     2018-02-01 CRAN (R 3.5.0)                 
    ##  webshot        0.5.0     2017-11-29 CRAN (R 3.5.0)                 
    ##  withr          2.1.2     2018-03-15 CRAN (R 3.5.0)                 
    ##  XML            3.98-1.11 2018-04-16 CRAN (R 3.5.0)                 
    ##  xml2           1.2.0     2018-01-24 CRAN (R 3.5.0)                 
    ##  xtable         1.8-2     2016-02-05 CRAN (R 3.5.0)                 
    ##  yaml           2.1.19    2018-05-01 CRAN (R 3.5.0)                 
    ##  zip            1.0.0     2017-04-25 CRAN (R 3.5.0)

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
