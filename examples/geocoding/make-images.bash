#! /bin/bash

echo "Building the 'postgis' image."
pushd ../../containers
docker-compose -f small.yml build
popd

echo "Building the 'geocoder' image."
docker-compose build

echo "Bringing the 'geocoder' service up."
echo "This will run quite some time."
echo "It is downloading data, building a database and backing it up."
docker-compose up

echo "Shutting the 'geocoder' service down."
docker-compose down
