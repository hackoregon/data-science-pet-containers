#! /bin/bash

if [ `( ls -1 /home/postgres/Backups/*.backup 2>/dev/null || true ) | wc -l` -gt "0" ]
then
  for file in /home/postgres/Backups/*.backup
  do
    echo "Restoring $file"
    filename=$(basename "$file")
    extension="${filename##*.}"
    filename="${filename%.*}"
    dropdb ${filename} || true
    createdb ${filename}
    pg_restore --verbose --dbname=${filename} $file
    echo "Restore completed"
  done
fi
