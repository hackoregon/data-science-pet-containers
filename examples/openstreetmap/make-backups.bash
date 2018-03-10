#! /bin/bash

for mode in cars bicycles pedestrian
do
  echo "Backing up schema $mode"
  pg_dump --format=custom --schema=$mode --dbname=osm_routing > osm_routing_$mode.backup
done
