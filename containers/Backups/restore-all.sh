#! /bin/bash

if [ `( ls -1 /home/dbsuper/Backups/*.backup 2>/dev/null || true ) | wc -l` -gt "0" ]
then
  for file in /home/dbsuper/Backups/*.backup
  do
    echo "Restoring $file"
    export DBNAME=`pg_restore --list $file | grep dbname | sed 's;^.*dbname: ;;'`
    echo "Creating '$DBNAME' with owner 'postgres'"
    createdb --owner=postgres $DBNAME
    pg_restore --exit-on-error --dbname=$DBNAME $file
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
