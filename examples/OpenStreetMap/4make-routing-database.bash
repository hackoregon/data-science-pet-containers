#! /bin/bash

for mode in cars bicycles pedestrian
do
  echo "Dropping old schema $mode"
  psql -d osm_routing -c "DROP SCHEMA IF EXISTS $mode CASCADE;"
  echo "Creating schema $mode"
  psql -d osm_routing -c "CREATE SCHEMA $mode;"
  echo "Loading data for $mode"
  time osm2pgrouting --conf /usr/share/osm2pgrouting/mapconfig_for_$mode.xml --schema $mode \
  --username postgres --dbname osm_routing --file trimet-latest.osm --addnodes
done

echo "Backing up osm_routing"
time pg_dump --format=custom --dbname=osm_routing > osm_routing.backup
