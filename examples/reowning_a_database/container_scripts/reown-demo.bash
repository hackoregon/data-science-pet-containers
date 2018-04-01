#! /bin/bash

export OWNER=disaster-resilience
export BACKUP_NAME=disaster
export DATABASE=$OWNER-$BACKUP_NAME
echo "Dropping database $DATABASE; ignore the error if it doesn't exist"
dropdb $DATABASE || true

echo "Creating a new database '$DATABASE' owned by '$OWNER'"
createdb --owner $OWNER $DATABASE

echo "Restoring the database"
pg_restore --dbname=$DATABASE --no-owner /home/dbsuper/Raw/$BACKUP_NAME.backup
echo "Reassigning ownership"
psql -d $DATABASE -c 'REASSIGN OWNED BY dbsuper TO "disaster-resilience";'

echo "Making a compressed SQL backup"
pg_dump -Fp -C -c --if-exists -d $DATABASE \
  | gzip -c > /home/dbsuper/Backups/$DATABASE.sql.gz
