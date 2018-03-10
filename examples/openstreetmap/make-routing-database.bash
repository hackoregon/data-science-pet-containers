#! /bin/bash

echo "Creating database osm_routing"
createdb osm_routing
echo "Creating extensions"
psql -d osm_routing -c "CREATE EXTENSION postgis;"
psql -d osm_routing -c "CREATE EXTENSION pgrouting;"
psql -d osm_routing -c "CREATE EXTENSION hstore;"
echo "Creating schemas"
psql -d osm_routing -c "CREATE SCHEMA cars;"
psql -d osm_routing -c "CREATE SCHEMA bicycles;"
psql -d osm_routing -c "CREATE SCHEMA pedestrian;"
echo "Loading data for cars"
osm2pgrouting --conf /usr/share/osm2pgrouting/mapconfig_for_cars.xml --schema cars \
  --username postgres --password $PGPASSWORD --host postgis --dbname osm_routing --file oregon-latest.osm \
  --addnodes --attributes --tags --clean
echo "Loading data for bicycles"
osm2pgrouting --conf /usr/share/osm2pgrouting/mapconfig_for_bicycles.xml --schema bicycles \
  --username postgres --password $PGPASSWORD --host postgis --dbname osm_routing --file oregon-latest.osm \
  --addnodes --attributes --tags --clean
echo "Loading data for pedestrian"
osm2pgrouting --conf /usr/share/osm2pgrouting/mapconfig_for_pedestrian.xml --schema pedestrian \
  --username postgres --password $PGPASSWORD --host postgis --dbname osm_routing --file oregon-latest.osm \
  --addnodes --attributes --tags --clean
