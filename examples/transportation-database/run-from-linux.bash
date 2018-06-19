#! /bin/bash

echo "Copying the scripts to the container"
docker cp container_scripts containers_postgis_1:/home/dbsuper

echo "Copying raw data to the container"
docker cp ~/Raw/Portland_Fatal___Injury_Crashes_2004-2014_Decode.mdb containers_postgis_1:/home/dbsuper/Raw
docker cp ~/Raw/passenger_census.csv containers_postgis_1:/home/dbsuper/Raw
docker cp ~/Raw/Safety_Hotline_Tickets.csv containers_postgis_1:/home/dbsuper/Raw
docker cp ~/Raw/scrapes.rar containers_postgis_1:/home/dbsuper/Raw
docker cp ~/Raw/April\ 2018.rar containers_postgis_1:/home/dbsuper/Raw
docker cp ~/Raw/May\ 2018.rar containers_postgis_1:/home/dbsuper/Raw
docker cp ~/Raw/sensor_locations.json containers_postgis_1:/home/dbsuper/Raw
docker cp ~/Raw/Nov_Disturbance_Stops.csv containers_postgis_1:/home/dbsuper/Raw
docker cp ~/Raw/May_Disturbance_Stops.csv containers_postgis_1:/home/dbsuper/Raw
docker cp ~/Raw/Sept_Disturbance_Stops.csv containers_postgis_1:/home/dbsuper/Raw
docker cp ~/Raw/Apr_Disturbance_Stops.csv containers_postgis_1:/home/dbsuper/Raw
docker cp ~/Raw/Oct_Disturbance_Stops_Test.csv containers_postgis_1:/home/dbsuper/Raw
docker cp ~/Raw/annual_route_difference_with_shapes.csv containers_postgis_1:/home/dbsuper/Raw
docker cp ~/Raw/route_shapes_final-2.csv containers_postgis_1:/home/dbsuper/Raw

echo "Running the scripts in the container"
echo ""
echo ""
docker exec -it -u dbsuper -w /home/dbsuper/container_scripts containers_postgis_1 \
  ./create-all-tables.bash

echo "Retriving the backups"
docker cp containers_postgis_1:home/dbsuper/Raw/transportation-systems-main.sql.gz ~/Raw/
docker cp containers_postgis_1:home/dbsuper/Raw/transportation-systems-main.sql.gz.sha512sum ~/Raw/
pushd ~/Raw/
echo "Validating backup sha512sum"
sha512sum -c transportation-systems-main.sql.gz.sha512sum
echo "Testing backup decompression"
gzip -dc transportation-systems-main.sql.gz | wc -c
