#! /bin/bash

echo "Dropping database; ignore the error if it doesn't exist"
dropdb $DB_NAME || true

echo "Creating a new database '$DB_NAME' owned by '$USER'"
createdb --owner $USER $DB_NAME

echo "Restoring the database as '$USER'"
pg_restore --dbname=$DB_NAME --no-owner $DB_NAME.backup

echo "Making a compressed SQL backup"
pg_dump -Fp -C -c --if-exists -d $DB_NAME | gzip -c > $DB_NAME.sql.gz
ls -ltr $DB_NAME.*
