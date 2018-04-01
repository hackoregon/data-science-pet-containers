#! /bin/bash

echo "Copying the scripts to the container"
docker cp osm_scripts containers_postgis_1:/home/dbsuper

echo "Installing OSM tools if needed"
docker exec -it -u root -w /usr/local/src containers_postgis_1 ./osm.bash

echo "Running the scripts in the container"
echo ""
echo ""
docker exec -it -u dbsuper -w /home/dbsuper/osm_scripts containers_postgis_1 \
  ./1create-routing-database.bash
docker exec -it -u dbsuper -w /home/dbsuper/osm_scripts containers_postgis_1 \
  ./2load-trimet-data.bash
docker exec -it -u dbsuper -w /home/dbsuper/osm_scripts containers_postgis_1 \
  ./3download-osm-data.bash
docker exec -it -u dbsuper -w /home/dbsuper/osm_scripts containers_postgis_1 \
  ./4make-routing-database.bash

echo "Retriving the backups"
docker cp containers_postgis_1:home/dbsuper/Backups ../../containers
ls -ltr ../../containers/Backups
