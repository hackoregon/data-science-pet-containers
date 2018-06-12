# function definitions

## load a "trimet_stop_event" CSV file
#' load_csv
#'
#' @param path path to a TriMet "trimet_stop_event" CSV file
#'
#' @return a tibble with the data from the file
load_csv <- function(path) {
  temp <- read_csv(
    path,
    col_types = cols(
      SERVICE_DATE = col_date(format = "%d%b%Y:%H:%M:%S"),
      VEHICLE_NUMBER = col_integer(),
      PATTERN_DISTANCE = col_double(),
      X_COORDINATE = col_double(),
      Y_COORDINATE = col_double()
    )
  )

  # drop unwanted columns
  temp <- temp %>% select(
    -BADGE,
    -MAXIMUM_SPEED,
    -PATTERN_DISTANCE,
    -LOCATION_DISTANCE,
    -DATA_SOURCE,
    -SCHEDULE_STATUS
  )

  # convert the service data to character - makes filtering easier
  temp$SERVICE_DATE <- as.character(temp$SERVICE_DATE)
  return(temp)
}

#' filter_unwanted_rows
#'
#' @param stop_events a stop_events tibble
#'
#' @return the tibble minus unwanted rows
filter_unwanted_rows <- function(stop_events) {
  temp <- stop_events %>% filter(
    LOCATION_ID > 0,
    ROUTE_NUMBER > 0,
    ROUTE_NUMBER <= 291,
    SERVICE_KEY == "W" |
      SERVICE_KEY == "S" |
      SERVICE_KEY == "U" |
      SERVICE_KEY == "X"
  )
  return(temp)
}

#' group_by_trips
#'
#' @param stop_events a "stop events" tibble
#'
#' @return the tibble grouped by trips
group_by_trips <- function(stop_events) {

  # sort first to get each trip in chronological order
  temp <- stop_events %>% arrange(
    SERVICE_DATE,
    VEHICLE_NUMBER,
    LEAVE_TIME) %>%
  group_by(
    SERVICE_DATE,
    VEHICLE_NUMBER,
    TRAIN,
    ROUTE_NUMBER,
    DIRECTION,
    TRIP_NUMBER
  )
  return(temp)
}

#' compute_lagged_columns
#' Once we have the data grouped by trips and ordered by time of day,
#' we add columns for the previous location ID and the time the vehicle
#' left there.
#'
#' Then we compute the travel time and travel distance between the stops.
#' Finally, we ungroup and filter out the outliers.
#' @param stop_events a stop_events tibble
#'
#' @return the tibble with the new columns
compute_lagged_columns <- function(stop_events) {
  temp <- stop_events %>% mutate(
    SECONDS_LATE = ARRIVE_TIME - STOP_TIME,
    FROM_LOCATION = lag(LOCATION_ID),
    MILEAGE_THERE = lag(TRAIN_MILEAGE),
    LEFT_THERE = lag(LEAVE_TIME),
    TRAVEL_MILES = TRAIN_MILEAGE - MILEAGE_THERE,
    TRAVEL_SECONDS = ARRIVE_TIME - LEFT_THERE
  )
  return(temp)
}

compute_trip_table <- function(stop_events) {
  trips <- stop_events %>% summarize(
    stops = n(),
    min_seconds = min(TRAVEL_SECONDS, na.rm = TRUE),
    max_seconds = max(TRAVEL_SECONDS, na.rm = TRUE)
  )
  return(trips)
}

compute_route_summary <- function(trips) {
  temp <- trips %>% group_by(ROUTE_NUMBER, DIRECTION)
  temp <- temp %>% summarize(
    p05 = quantile(stops, probs = 0.05, names = FALSE, na.rm = TRUE),
    p95 = quantile(stops, probs = 0.95, names = FALSE, na.rm = TRUE)
  )
  return(temp)
}

compute_bad_trips <- function(trips) {
  temp <- trips %>% filter(
    is.infinite(min_seconds) |
      is.infinite(max_seconds) |
      stops < p05 |
      stops > p95 |
      min_seconds < 0
  )
  return(temp)
}

# temp <- temp %>% ungroup()
#
#   # remove outliers
#   seconds_low_cutoff <- quantile(
#     temp$TRAVEL_SECONDS, names = FALSE, na.rm = TRUE, probs = 0.05)
#   miles_low_cutoff <- quantile(
#     temp$TRAVEL_MILES, names = FALSE, na.rm = TRUE, probs = 0.05)
#   seconds_high_cutoff <- quantile(
#     temp$TRAVEL_SECONDS, names = FALSE, na.rm = TRUE, probs = 0.95)
#   miles_high_cutoff <- quantile(
#     temp$TRAVEL_MILES, names = FALSE, na.rm = TRUE, probs = 0.95)
#   temp <- temp %>% filter(
#     !is.na(TRAVEL_SECONDS),
#     TRAVEL_SECONDS > seconds_low_cutoff,
#     TRAVEL_MILES > miles_low_cutoff,
#     TRAVEL_SECONDS < seconds_high_cutoff,
#     TRAVEL_MILES < miles_high_cutoff
#   )

#' select_output_columns
#'
#' @param stop_events a stop_events tibble
#'
#' @return the selected columns
select_output_columns <- function(stop_events) {
  temp <- stop_events %>% select(
    SERVICE_DATE,
    VEHICLE_NUMBER,
    TRAIN,
    ROUTE_NUMBER,
    DIRECTION,
    TRIP_NUMBER,
    SERVICE_KEY,
    STOP_TIME,
    ARRIVE_TIME,
    SECONDS_LATE,
    LEAVE_TIME,
    DWELL,
    LOCATION_ID,
    DOOR,
    LIFT,
    ONS,
    OFFS,
    ESTIMATED_LOAD,
    TRAIN_MILEAGE,
    FROM_LOCATION,
    MILEAGE_THERE,
    LEFT_THERE,
    TRAVEL_MILES,
    TRAVEL_SECONDS,
    X_COORDINATE,
    Y_COORDINATE
  )
  return(temp)
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

## filter for selecting routes
routes_4_14_73 <- function(stop_events) {
  temp <- stop_events %>%
    filter(
      ROUTE_NUMBER == 4 |
        ROUTE_NUMBER == 14 |
        ROUTE_NUMBER == 73
    )
  return(temp)
}
