#! /bin/bash

echo "Starting database service."
pg_ctl start -D=$PGDATA

echo "Changing to 'postgres' home directory."
cd /home/postgres

echo "Testing for existing geocoder database"
export GEOCODER=`psql -lqt | cut -d \| -f 1 | grep -cw geocoder`
echo "GEOCODER = $GEOCODER"
if [ $GEOCODER -gt "0" ]
then
  echo "geocoder database exists = exiting!"
  exit
fi

echo "Creating a geocoder database"
createdb -O postgres geocoder
psql -d geocoder -f extensions.sql

echo "Creating the /gisdata workspace"
mkdir -p /gisdata/temp
chown -R ${USER}:${USER} /gisdata

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

echo "Installing any missing indexes"
psql -d geocoder -c "SELECT install_missing_indexes();"
echo "Creating a dump of the geocoder database"
pg_dump -Fc geocoder > /gisdata/geocoder.backup

./test-geocoder.bash
