#! /bin/bash

echo "Copying the scripts to the container"
docker cp container_scripts containers_postgis_1:/home/dbsuper

echo "Copying raw data to the container"
docker cp ~/Raw/Portland_Fatal___Injury_Crashes_2004-2014_Decode.mdb containers_postgis_1:/home/dbsuper/Raw
docker cp ~/Raw/passenger_census.csv containers_postgis_1:/home/dbsuper/Raw
docker cp ~/Raw/Safety_Hotline_Tickets.csv containers_postgis_1:/home/dbsuper/Raw
docker cp ~/Raw/scrapes.rar containers_postgis_1:/home/dbsuper/Raw

echo "Running the scripts in the container"
echo ""
echo ""
docker exec -it -u dbsuper -w /home/dbsuper/container_scripts containers_postgis_1 \
  ./create-all-tables.bash

echo "Retriving the backups"
docker cp containers_postgis_1:home/dbsuper/Raw/transportation-systems-main.sql.gz ~/Raw/
ls -ltr ~/Raw
