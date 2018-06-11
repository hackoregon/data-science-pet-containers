#! /bin/bash

pushd ~/Raw/trimet-gtfs-archives

for zipfile in *.zip
do
  echo "Extracting calendar_dates, trips and shapes from ${zipfile}"
  csvname=`echo ${zipfile}|sed 's/zip$/csv/'`
  unzip -p ${zipfile} calendar_dates.txt > calendar_dates_${csvname}
  unzip -p ${zipfile} trips.txt > trips_${csvname}
  unzip -p ${zipfile} shapes.txt > shapes_${csvname}
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

echo "Stacking shapes"
grep -h service_id shapes_*.csv | head -n 1
grep -h service_id shapes_*.csv | head -n 1 > shapes_catalog.csv
/usr/bin/time tail -n +2 -q shapes_*csv |dos2unix|sort -u >> shapes_catalog.csv
wc -l shapes_catalog.csv

popd
