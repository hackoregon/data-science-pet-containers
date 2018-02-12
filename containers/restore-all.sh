#! /bin/bash

if [ -z "$(ls -A /home/postgres/Backups/*.backup)" ]
then
   echo "No backup files - exiting"
   exit
fi
for file in /home/postgres/Backups/*.backup
do
  filename=$(basename "$file")
  extension="${filename##*.}"
  filename="${filename%.*}"
  dropdb ${filename} || true
  createdb ${filename}
  pg_restore --verbose --dbname=${filename} $file
done
