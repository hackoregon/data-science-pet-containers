#! /bin/bash

export PGHOST=localhost
export PGPORT=5439
export PGUSER=postgres
echo "Testing the geocoder - compare lon and lat with Google Maps"
psql -d geocoder -f test-geocoder.sql
