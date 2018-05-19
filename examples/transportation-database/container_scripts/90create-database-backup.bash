#! /bin/bash

# define parameters
export DBOWNER=transportation-systems
export PGDATABASE=transportation-systems-main

echo "Creating the database backup"
pushd ~/Raw/
pg_dump --format=p --verbose --clean --create --if-exists --dbname=${PGDATABASE} \
  | gzip -c > ${PGDATABASE}.sql.gz

echo "Decompression check"
gzip -dc ${PGDATABASE}.sql.gz | wc -c

echo "Checksumming backup file"
sha512sum ${PGDATABASE}.sql.gz > ${PGDATABASE}.sql.gz.sha512sum
sha512sum -c ${PGDATABASE}.sql.gz.sha512sum
