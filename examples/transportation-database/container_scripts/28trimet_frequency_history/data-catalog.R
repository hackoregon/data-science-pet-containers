#! /usr/bin/env Rscript

library(tidyverse)
here <- setwd("~/Raw/trimet-gtfs-archives")
zipfiles <- list.files(
  path = ".",
  pattern = ".zip"
)
calendar_dates_catalog <- trips_catalog <- tibble()

for (zipfile in zipfiles) {
  import <- gtfsr::import_gtfs(zipfile, local = TRUE)
  trips <- import$trips_df %>% mutate(source = zipfile)
  calendar_dates <- import$calendar_dates_df %>% mutate(source = zipfile)
  rm(import); gc(full = TRUE, verbose = TRUE)
  trips_catalog <- trips_catalog %>% bind_rows(trips)
  calendar_dates_catalog <- calendar_dates_catalog %>% bind_rows(calendar_dates)
}

trips_catalog %>% write_csv(path = "~/Raw/trips_catalog.csv")
calendar_dates_catalog %>%  write_csv(path = "~/Raw/calendar_dates_catalog.csv")
