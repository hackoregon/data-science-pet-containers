#! /usr/bin/env Rscript

## croak on warning!
options(warn = 2)

## load libraries
library(tidyverse)
source("function_definitions.R")

## load the PUDL table
pudl <- read_csv("pudl.csv")

## define the route filter
route_filter <- function(stop_events) {
  temp <- stop_events %>%
  filter(ROUTE_NUMBER == 4 |
           ROUTE_NUMBER == 14 |
           ROUTE_NUMBER == 73
  )
}

## define the month table
month_table <- tibble::tribble(
  ~output_file, ~input_file,
  "~/Raw/m2017_09_trimet_stop_events.csv",
  "~/Raw/trimet_stop_event 1-30SEP2017.csv",
  "~/Raw/m2017_10_trimet_stop_events.csv",
  "~/Raw/trimet_stop_event 1-31OCT2017.csv",
  "~/Raw/m2017_11_trimet_stop_events.csv",
  "~/Raw/trimet_stop_event 1-30NOV2017.csv",
  "~/Raw/m2018_04_trimet_stop_events.csv",
  "~/Raw/trimet_stop_event 1-30APR2018.csv",
  "~/Raw/m2018_05_trimet_stop_events.csv",
  "~/Raw/trimet_stop_event 1-31MAY2018.csv"
)

## loop over months
for (i in 1:nrow(month_table)) {

  cat(paste("\nLoading", month_table$input_file[i], "\n"))
  gc(full = TRUE, verbose = TRUE)
  trimet_stop_events <- load_csv(month_table$input_file[i])
  gc(full = TRUE, verbose = TRUE)

  cat("\nFilter in selected routes\n")
  trimet_stop_events <- trimet_stop_events %>%
    route_filter()
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

  cat("\nRestricting to PUDL street segments\n")
  trimet_stop_events <- trimet_stop_events %>%
    semi_join(
      pudl,
      by = c("ROUTE_NUMBER" = "rte", "DIRECTION" = "dir", "LOCATION_ID" = "stop_id")
    )
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

# reformat the disturbance stops table
cat(paste("\nFixing dates on disturbance stop table\n"))
options(warn = 0)
disturbance_stops <- read_csv(
  "~/Raw/Lines4_14_73_Disturbance_Stops.csv",
  col_types = cols(
    .default = col_character(),
    OPD_DATE_x = col_date(format = "%d%b%Y:%H:%M:%S"),
    OPD_DATE_y = col_date(format = "%d%b%Y:%H:%M:%S")
  )
)
colnames(disturbance_stops)[1] <- "serial"
colnames(disturbance_stops) <- tolower(colnames(disturbance_stops))
disturbance_stops %>% write_csv(
  "~/Raw/disturbance_stops.csv",
  na = ""
)
problems(disturbance_stops)
