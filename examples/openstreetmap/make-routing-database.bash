#! /bin/bash

echo "Creating database osm_routing"
dropdb osm_routing || true # don't quit if database doesn't exist
createdb osm_routing
echo "Creating extensions"
psql -d osm_routing -c "CREATE EXTENSION postgis;"
psql -d osm_routing -c "CREATE EXTENSION pgrouting;"
psql -d osm_routing -c "CREATE EXTENSION hstore;"

for mode in cars bicycles pedestrian
do
  echo "Creating schema $mode"
  psql -d osm_routing -c "CREATE SCHEMA $mode;"
  echo "Loading data for $mode"
  osm2pgrouting --conf /usr/share/osm2pgrouting/mapconfig_for_$mode.xml --schema $mode \
  --username postgres --password $PGPASSWORD --host postgis --dbname osm_routing --file trimet-latest.osm \
  --addnodes
done

echo "Backing up osm_routing"
pg_dump --format=custom --dbname=osm_routing > osm_routing.backup
