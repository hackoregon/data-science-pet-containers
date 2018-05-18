#! /bin/bash

# define parameters
export DBOWNER=transportation-systems
export PGDATABASE=transportation-systems-main

for schema in 2trimet-stop-events 3odot-crash-data 4passenger-census 5trimet-shapefiles 6safety-hotline
do
  pushd ${schema}
  ./create-tables
  popd
done
