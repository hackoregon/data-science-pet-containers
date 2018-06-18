#! /usr/bin/env Rscript

library(tidyverse)
library(jsonlite)
library(snakecase)
from_json <- fromJSON("~/Raw/sensor_locations.json", flatten = TRUE)
sensor_locations <- from_json[["content"]]
colnames(sensor_locations) <- to_snake_case(colnames(sensor_locations))

# deal with the list column `event_types`
string_collapse <- function(x) {paste(x, collapse = ",")}
sensor_locations$event_types <- sensor_locations$event_types %>%
  lapply(string_collapse) %>% unlist()
sensor_locations <- sensor_locations %>% mutate(
  longitude = sub("^.*:", "", coordinates) %>% as.numeric(),
  latitude = sub(":.*$", "", coordinates) %>% as.numeric()) %>%
  group_by(longitude, latitude) %>%
  summarize(asset_count = n()) %>%
  ungroup() %>%
  write_csv("~/Raw/sensor_locations.csv")
