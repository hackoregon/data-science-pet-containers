#! /bin/bash

# create the users we'll be restoring to!
for user in $DB_USERS_TO_CREATE
do
  echo "Creating database user $user with home database $user"
  createuser --no-createdb --no-createrole --no-superuser --no-replication $user || true
  createdb --owner=$user $user || true
done

if [ `( ls -1 /home/dbsuper/Backups/*.backup 2>/dev/null || true ) | wc -l` -gt "0" ]
then
  for file in /home/dbsuper/Backups/*.backup
  do
    echo "Restoring $file"
    pg_restore --verbose --exit-on-error --create --clean --if-exists $file
    echo "Restore completed"
  done
fi

if [ `( ls -1 /home/dbsuper/Backups/*.sql.gz 2>/dev/null || true ) | wc -l` -gt "0" ]
then
  for file in /home/dbsuper/Backups/*.sql.gz
  do
    echo "Restoring $file"
    gzip -dc $file | psql
    echo "Restore completed"
  done
fi

if [ `( ls -1 /home/dbsuper/Backups/*.sql 2>/dev/null || true ) | wc -l` -gt "0" ]
then
  for file in /home/dbsuper/Backups/*.sql
  do
    echo "Restoring $file"
    psql < $file
    echo "Restore completed"
  done
fi
