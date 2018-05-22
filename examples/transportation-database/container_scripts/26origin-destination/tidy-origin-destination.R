#! /usr/bin/env Rscript

library(tidyverse)

cat("\nReading the 'crosswalk' file\n")
or_xwalk <- read_csv(
  "~/Raw/or_xwalk.csv",
  col_types = cols(.default = col_character())
)

# filter down to metro area
metro_xwalk <- or_xwalk %>%
  filter(cbsaname == "Portland-Vancouver-Hillsboro, OR-WA") %>%
  select(
    tabblk2010
  )

cat("\nReading the 'origin_destination' file\n")
origin_destination <- read_csv(
  "~/Raw/origin_destination.csv",
  col_types = cols(
    h_geocode = col_character(),
    w_geocode = col_character()
  )) %>%
  select(-createdate)

cat("\nWriting 'metro_origin_destination.csv'\n")
metro_origin_destination <- origin_destination %>%
  inner_join(metro_xwalk, by = c("w_geocode" = "tabblk2010")) %>%
  inner_join(metro_xwalk, by = c("h_geocode" = "tabblk2010")) %>%
  write_csv(path = "~/Raw/metro_origin_destination.csv")
