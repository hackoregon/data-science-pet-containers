#! /usr/bin/env Rscript

library(tidyverse)
library(lubridate)
biketown <- read_csv(
  "~/Raw/biketown.csv",
  col_types = cols(
    .default = col_character(),
    start_latitude = col_double(),
    start_longitude = col_double(),
    start_date = col_date(format = "%m/%d/%Y"),
    start_time = col_time(format = "%H:%M"),
    end_latitude = col_double(),
    end_longitude = col_double(),
    end_date = col_date(format = "%m/%d/%Y"),
    end_time = col_time(format = "%H:%M"),
    distance_miles = col_double()
  )
) %>%
  filter(
    !is.na(start_latitude),
    !is.na(end_latitude),
    !is.na(duration),
    !is.na(distance_miles)
  )
biketown <- biketown %>% mutate(
  duration_minutes = as.numeric(
    as.duration(hms(biketown$duration)),
    "minutes"
  )
)

# replace missing hub names with GPS coordinates
biketown$start_hub <- ifelse(
  is.na(biketown$start_hub),
  paste(
    "GPS(",
    biketown$start_longitude,
    ",",
    biketown$start_latitude,
    ")", sep = ""
  ),
  biketown$start_hub
)
biketown$end_hub <- ifelse(
  is.na(biketown$end_hub),
  paste(
    "GPS(",
    biketown$end_longitude,
    ",",
    biketown$end_latitude,
    ")", sep = ""
  ),
  biketown$end_hub
)

biketown %>% write_csv(
  path = "~/Raw/cleaned_biketown.csv",
  na = ""
)
