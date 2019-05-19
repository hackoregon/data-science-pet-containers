#! /bin/bash

echo "Copying the scripts to the container"
sudo docker cp osm_scripts containers_postgis_1:/home/dbsuper

echo "Installing OSM tools if needed"
sudo docker exec -it -u root -w /usr/local/src containers_postgis_1 ./osm.bash

echo "Running the scripts in the container"
echo ""
echo ""
sudo docker exec -it -u dbsuper -w /home/dbsuper/osm_scripts containers_postgis_1 \
  ./1create-routing-database.bash
sudo docker exec -it -u dbsuper -w /home/dbsuper/osm_scripts containers_postgis_1 \
  ./2load-trimet-data.bash
sudo docker exec -it -u dbsuper -w /home/dbsuper/osm_scripts containers_postgis_1 \
  ./3download-osm-data.bash
sudo docker exec -it -u dbsuper -w /home/dbsuper/osm_scripts containers_postgis_1 \
  ./4make-routing-database.bash

echo "Retriving the backups"
sudo docker cp containers_postgis_1:home/dbsuper/Raw ../../containers
ls -ltr ../../containers/Raw
