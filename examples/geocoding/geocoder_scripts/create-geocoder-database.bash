#! /bin/bash

echo "Dropping geocoder database; ignore error if it does not exist"
dropdb geocoder || true

echo "Creating a geocoder database"
createdb -O postgres geocoder
psql -d geocoder -f extensions.sql

echo "Creating the /gisdata workspace"
mkdir -p /gisdata/temp

echo "Populating the database - this will take some time."
for i in nation oregon
do
  psql -d geocoder -f make-$i-script.psql
  pushd /gisdata
  sed -i -e '/PGHOST/d' $i.bash
  sed -i -s 's/wget/wget -q/g' $i.bash
  chmod +x $i.bash
  ./$i.bash
  popd
done

echo "Post-processing and test"
psql -d geocoder -f post-processing.sql
echo "Creating a dump of the geocoder database"
pg_dump -Fc geocoder > /gisdata/geocoder.backup
