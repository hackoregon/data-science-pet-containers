#! /bin/bash

echo "Copying the scripts to the container"
docker cp container_scripts containers_postgis_1:/home/dbsuper

echo "Copying raw data to the container"
docker cp ~/Raw containers_postgis_1:/home/dbsuper

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
