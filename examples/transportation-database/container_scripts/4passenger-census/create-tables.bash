#! /bin/bash

# define parameters
export DBOWNER=transportation-systems
export PGDATABASE=transportation-systems-main

echo "Importing passenger_census.csv"
psql -U ${DBOWNER} -d ${PGDATABASE} -f "passenger-census.psql"
