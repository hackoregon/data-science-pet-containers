#! /bin/bash

if [ `( ls -1 /home/dbsuper/Backups/*.backup 2>/dev/null || true ) | wc -l` -gt "0" ]
then
  for file in /home/dbsuper/Backups/*.backup
  do
    echo "Restoring $file"
    filename=$(basename "$file")
    extension="${filename##*.}"
    filename="${filename%.*}"
    dropdb ${filename} || true
    createdb ${filename}
    pg_restore --verbose --no-owner --dbname=${filename} $file
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
