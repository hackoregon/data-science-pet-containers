#! /bin/bash

# define parameters
export DBOWNER=transportation-systems
export PGDATABASE=transportation-systems-main

echo "Creating the database backup"
pg_dump --format=p --verbose --clean --create --if-exists --dbname=${PGDATABASE} \
  | gzip -c > ~/Raw/${PGDATABASE}.sql.gz
