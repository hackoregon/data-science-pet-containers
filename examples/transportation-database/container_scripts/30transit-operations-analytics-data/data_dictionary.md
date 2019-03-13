Data Dictionary
================

## CSV files

There are three CSV files, one for each month in the raw dataset TriMet
gave us:

  - m2017\_09\_trimet\_stop\_events.csv
  - m2017\_10\_trimet\_stop\_events.csv
  - m2017\_11\_trimet\_stop\_events.csv

There are no dependencies between months, so you can develop / test with
a single month if you’re short on RAM. The CSV files are about 850
megabytes each.

## GIS data

The CSV files and the database table built from them do *not* have any
GIS columns. The X and Y coordinates from the input files are not
consistent by location and have been dropped. Instead, you will have to
JOIN with the TriMet `tm_route_stops` table if you want to do geometry /
geography processing.

The route stops table shapefile can be found at
<https://developer.trimet.org/gis/data/tm_route_stops.zip>. This table
will be in the database.

## Column definitions

### Grouping columns

These are the grouping columns that define a trip. Their official
definitions can be found at
<https://developer.trimet.org/definitions.shtml>.

  - service\_date date – the date of the trip
  - vehicle\_number integer – the vehicle number
  - train integer – the “Train / Block” number
  - route\_number integer – the route number
  - direction integer – the direction
  - trip\_number integer – the trip number

### Given columns about the stop event

  - service\_key text –
      - W = Weekday
      - S = Saturday
      - U = Sunday
      - X = Holiday/Extra Service
  - stop\_time integer – the time (seconds of day) the vehicle was
    *scheduled* to arrive
  - arrive\_time integer – the time it actually arrived
  - leave\_time integer – the time the vehicle left the stop
  - dwell integer – `leave_time - arrive_time`
  - location\_id integer – the location number
  - door integer – how many doors opened
  - lift integer – did the lift operate?
  - ons integer – how many passengers got on
  - offs integer – how many passengers got off
  - estimated\_load integer – how many passengers were on the vehicle
    when it left
  - train\_mileage double precision – the mileage on the vehicle when it
    arrived

### Calculated columns

The remaining columns were derived by the following process.

1.  Group the dataset by trips, using the grouping columns defined
    above. Within each trip, order by `arrive_time`.
2.  For each trip, append columns lagged by one stop. These columns are
      - from\_location integer – the `location_id` of the previous stop
      - mileage\_there double precision – the `train_mileage` of the
        previous stop
      - left\_there integer – the `leave_time` of the previous stop.
3.  Calculate the relevant differences.
      - seconds\_late integer – `arrive_time - stop_time` (can be
        negative if it arrived early)
      - travel\_miles double precision – `train_mileage - mileage_there`
      - travel\_seconds integer – `arrive_time - left_there`.

## Road map

1.  Finish the database. I have most of the code working but I need to
    add some sanity checks.
2.  Test database restores.
