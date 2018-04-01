#! /bin/bash

if [ ! -e ../../containers/Raw/passenger_census.csv ]
then
  echo "Input file ../../containers/Raw/passenger_census.csv does not exist - exiting!"
  exit
fi

echo "Copying raw data to the container"
docker cp ../../containers/Raw containers_postgis_1:/home/dbsuper

echo "Copying the scripts to the container"
docker cp container_scripts containers_postgis_1:/home/dbsuper

echo "Running the script in the container"
echo ""
echo ""
docker exec -it -u dbsuper -w /home/dbsuper/container_scripts containers_postgis_1 ./make_database_backups.bash

echo "Retriving the backups"
docker cp containers_postgis_1:home/dbsuper/Backups ../../containers
ls -ltr ../../containers/Backups
