#! /bin/bash

if [ ! -e ../../containers/Raw/Portland_Fatal___Injury_Crashes_2004-2014_Decode.mdb ]
then
  echo "Input file ../../containers/Raw/Portland_Fatal___Injury_Crashes_2004-2014_Decode.mdb does not exist - exiting!"
  exit
fi

echo "Copying raw data to the container"
docker cp ../../containers/Raw containers_postgis_1:/home/dbsuper

echo "Copying the scripts to the container"
docker cp odot_crash_data_scripts containers_postgis_1:/home/dbsuper

echo "Running the script in the container"
echo ""
echo ""
docker exec -it -u dbsuper -w /home/dbsuper/odot_crash_data_scripts containers_postgis_1 ./migrate.bash

echo "Retriving the backups"
docker cp containers_postgis_1:home/dbsuper/Raw ../../containers
ls -ltr ../../containers/Raw
