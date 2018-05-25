#! /usr/bin/env Rscript

## croak on warning!
options(warn = 2)

## load libraries
library(tidyverse)
source("function_definitions.R")

## loop over months
for (i in 1:nrow(month_table)) {

  cat(paste("\nLoading", month_table$input_file[i], "\n"))
  gc(full = TRUE, verbose = TRUE)
  trimet_stop_events <- load_csv(month_table$input_file[i])
  gc(full = TRUE, verbose = TRUE)

  cat("\nRemoving unwanted rows\n")
  trimet_stop_events <- trimet_stop_events %>%
    filter_unwanted_rows()
  gc(full = TRUE, verbose = TRUE)

  cat("\nGrouping by trips\n")
  trimet_stop_events <- trimet_stop_events %>%
    group_by_trips()
  gc(full = TRUE, verbose = TRUE)

  cat("\nComputing lagged columns\n")
  trimet_stop_events <- trimet_stop_events %>%
    compute_lagged_columns()
  gc(full = TRUE, verbose = TRUE)

  cat("\nFiltering out bad trips\n")
  trips <- compute_trip_table(trimet_stop_events)
  gc(full = TRUE, verbose = TRUE)
  routes <- compute_route_summary(trips)
  gc(full = TRUE, verbose = TRUE)
  trips <- trips %>% left_join(routes)
  gc(full = TRUE, verbose = TRUE)
  bad_trips <- trips %>%  compute_bad_trips()
  gc(full = TRUE, verbose = TRUE)
  trimet_stop_events <- trimet_stop_events %>%
    anti_join(bad_trips) %>%
    filter(!is.na(TRAVEL_SECONDS))
  gc(full = TRUE, verbose = TRUE)

  cat(paste("\nSaving", month_table$output_file[i], "\n"))
  trimet_stop_events <- trimet_stop_events %>%
    select_output_columns()
  gc(full = TRUE, verbose = TRUE)
  colnames(trimet_stop_events) <- tolower(colnames(trimet_stop_events))
  trimet_stop_events %>% write_csv(
    month_table$output_file[i],
    na = ""
  )

  rm(trimet_stop_events)
  gc(full = TRUE, verbose = TRUE)

}
