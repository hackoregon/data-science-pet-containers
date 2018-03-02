#! /bin/bash

# source the environment variables the geocoder was built with
source .env

# set up variables for connection
export PGHOST=localhost
export PGPORT=${HOST_POSTGRES_PORT}
export PGUSER=postgres
export PGPASSWORD=${POSTGRES_PASSWORD}

echo "Testing the geocoder - compare lon and lat with Google Maps"
psql -d geocoder -f test-geocoder.sql
