#! /bin/bash

echo "Copying the code to the container"
docker cp geocoder_scripts containers_postgis_1:/usr/local/src/
docker exec -u root containers_postgis_1 \
  chown -R postgres:postgres /usr/local/src/geocoder_scripts
docker exec -u postgres -w /usr/local/src/geocoder_scripts containers_postgis_1 \
  /usr/local/geocoder_scripts/create-geocoder-database.bash
