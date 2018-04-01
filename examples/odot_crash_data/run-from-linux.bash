#! /bin/bash

if [ ! -e ../../containers/Raw/Portland_Fatal___Injury_Crashes_2004-2014_Decode.mdb ]
then
  echo "Input file ../../containers/Raw/Portland_Fatal___Injury_Crashes_2004-2014_Decode.mdb does not exist - exiting!"
  exit
fi

echo "Copying raw data to the container"
docker cp ../../containers/Raw containers_postgis_1:/home/dbsuper

echo "Copying the scripts to the container"
docker cp migrate.* containers_postgis_1:/home/dbsuper

echo "Running the script in the container"
echo ""
echo ""
docker exec -it -u dbsuper -w /home/dbsuper containers_postgis_1 /home/dbsuper/migrate.bash

echo "Retriving the backups"
docker cp containers_postgis_1:home/dbsuper/Backups ../../containers
ls -ltr ../../containers/Backups
