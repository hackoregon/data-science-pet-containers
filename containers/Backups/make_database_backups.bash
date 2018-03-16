#! /bin/bash

# assumes
# 1. Linux,
# 2. PostgreSQL with trust authentication for your user ID, You do *not* need PostGIS!
# 3. Your user ID has read privileges on the database $DBNAME.
# Most folks will run this as `dbsuper`.

echo "Creating the database backups"
pg_dump --format=p --verbose --clean --create --if-exists --dbname=$DBNAME \
  | gzip -c > /home/dbsuper/$DBNAME.sql.gz
pg_dump --format=c --verbose --clean --create --if-exists --dbname=$DBNAME \
  > /home/dbsuper/$DBNAME.backup
