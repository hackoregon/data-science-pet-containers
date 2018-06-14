library(tidyverse)
library(sp)
library(sf)
library(tmap)
passenger_census <- read_csv(
  "~/Raw/passenger_census.csv",
  col_types = cols(
    DIRECTION = col_integer(),
    LOCATION_ID = col_integer(),
    OFFS = col_integer(),
    ONS = col_integer(),
    PUBLIC_LOCATION_DESCRIPTION = col_character(),
    ROUTE_NUMBER = col_integer(),
    SERVICE_KEY = col_character(),
    STOP_SEQ = col_integer(),
    SUMMARY_BEGIN_DATE = col_date(format = "%d-%b-%y"),
    X_COORD = col_double(),
    Y_COORD = col_double()
  )
)
passenger_census <- SpatialPointsDataFrame(
  coords = select(passenger_census, X_COORD, Y_COORD),
  data = passenger_census,
  proj4string = CRS("+init=epsg:2913")
)
passenger_census <- spTransform(passenger_census, CRS("+init=epsg:4326")) %>%
  as("sf") %>%
  select(SUMMARY_BEGIN_DATE:Y_COORD, GEOM_4326 = geometry)
View(passenger_census)
tmap_mode("view")
qtm(passenger_census, symbols.col = "ONS")
