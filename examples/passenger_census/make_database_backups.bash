#! /bin/bash

# create the users we'll be restoring to!
for user in $DB_USERS_TO_CREATE
do
  echo "Creating database user $user with home database $user"
  createuser --no-createdb --no-createrole --no-superuser --no-replication $user || true
  createdb --owner=$user $user || true
done
echo "You can ignore errors in the user creation above"
sleep 5

echo "Creating the database"
psql -f make_database.sql
echo "Creating the database backups"
pg_dump --format=p --verbose --clean --create --if-exists --dbname=passenger_census \
  | gzip -c > /home/dbsuper/Backups/passenger_census.sql.gz
