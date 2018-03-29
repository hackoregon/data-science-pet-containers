#! /bin/bash

echo "Copying the code to the container"
docker cp geocoder_scripts containers_postgis_1:/usr/local/src/
docker exec -u root containers_postgis_1 \
  chown -R postgres:postgres /usr/local/src/geocoder_scripts
echo "Populating the database - will take some time!"
echo ""
echo ""
docker exec -u postgres -w /usr/local/src/geocoder_scripts containers_postgis_1 \
  /usr/local/geocoder_scripts/create-geocoder-database.bash
echo "Retriving database backup"
docker cp containers_postgis_1:/gisdata/geocoder.backup .
echo "Retriving shapefile archive"
docker cp containers_postgis_1:/gisdata/tiger.zip .
