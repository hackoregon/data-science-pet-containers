#! /bin/bash

echo "Creating the database"
psql -f make_database.sql
echo "Creating the database backups"
pg_dump --format=p --verbose --clean --create --if-exists --dbname=transportation-systems-passenger-census \
  | gzip -c > /home/dbsuper/Raw/transportation-systems-passenger-census.sql.gz
