#! /bin/bash

echo "Creating the database"
psql -f make_database.sql
echo "Creating the database backups"
pg_dump --format=p --verbose --clean --create --if-exists --dbname=passenger_census \
  | gzip -c > /home/dbsuper/Backups/passenger_census.sql.gz
pg_dump --format=c --verbose --dbname=passenger_census \
  > /home/dbsuper/Backups/passenger_census.backup
