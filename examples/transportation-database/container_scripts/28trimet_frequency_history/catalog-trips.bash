#! /bin/bash

pushd ~/Raw/trimet-gtfs-archives

for zipfile in *.zip
do
  echo "Extracting calendar_dates, trips and routes from ${zipfile}"
  csvname=`echo ${zipfile}|sed 's/zip$/csv/'`
  unzip -p ${zipfile} calendar_dates.txt > calendar_dates_${csvname}
  unzip -p ${zipfile} trips.txt > trips_${csvname}
  unzip -p ${zipfile} routes.txt > routes_${csvname}
done

echo "Stacking calendar_dates"
grep -h service_id calendar_dates_*.csv | head -n 1
grep -h service_id calendar_dates_*.csv | head -n 1 > calendar_dates_catalog.csv
/usr/bin/time tail -n +2 -q calendar_dates_*csv |dos2unix|sort -u >> calendar_dates_catalog.csv
wc -l calendar_dates_catalog.csv

echo "Stacking trips"
grep -h service_id trips_*.csv | head -n 1
grep -h service_id trips_*.csv | head -n 1 > trips_catalog.csv
/usr/bin/time tail -n +2 -q trips_*csv |dos2unix|sort -u >> trips_catalog.csv
wc -l trips_catalog.csv

echo "Stacking routes"
grep -h service_id routes_*.csv | head -n 1
grep -h service_id routes_*.csv | head -n 1 > routes_catalog.csv
/usr/bin/time tail -n +2 -q routes_*csv |dos2unix|sort -u >> routes_catalog.csv
wc -l routes_catalog.csv

popd
