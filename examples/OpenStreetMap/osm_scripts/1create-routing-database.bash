#! /bin/bash

echo "Creating fresh database 'osm_routing'; ignore error if it doesn't exist"
dropdb osm_routing || true # don't quit if database doesn't exist
createdb osm_routing
echo "Creating extensions"
psql -d osm_routing -c "CREATE EXTENSION postgis CASCADE;"
psql -d osm_routing -c "CREATE EXTENSION pgrouting CASCADE;"
psql -d osm_routing -c "CREATE EXTENSION hstore CASCADE;"
