#! /bin/bash

echo "Drop database; ignore error if it doesn't exist"
dropdb disaster || true

echo "Create a new database"
createdb --owner disaster-resilience disaster

echo "Restore it as the new owner"
pg_restore --dbname=disaster --no-owner /home/dbsuper/Raw/disaster.backup

echo "Make a compressed SQL backup"
pg_dump -Fp -C -c --if-exists -d disaster | gzip -c > disaster.sql.gz
ls -ltr
