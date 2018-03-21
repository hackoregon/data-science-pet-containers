#! /bin/bash

# source: https://www.postgresql.org/download/linux/ubuntu/

echo "Adding the PGDG repository"
sudo cp pgdg.list.trusty /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  sudo apt-key add -

echo "Updating the cache"
sudo apt-get update

echo "Installing PostgreSQL 9.6, PostGIS 2.4, pgRouting 2.5 and pgAdmin 4"
echo "This will take some time."
sudo apt-get install -y \
  gdal-bin \
  osm2pgsql \
  postgresql-9.6 \
  postgresql-9.6-mysql-fdw \
  postgresql-9.6-ogr-fdw \
  postgresql-9.6-pgrouting \
  postgresql-9.6-pgrouting-doc \
  postgresql-9.6-pgrouting-scripts \
  postgresql-9.6-postgis-2.4 \
  postgresql-9.6-postgis-2.4-scripts \
  postgresql-9.6-postgis-scripts \
  postgresql-client-9.6 \
  postgresql-doc-9.6 \
  postgresql-server-dev-9.6 \
  pgadmin4 \
  pgadmin4-doc

echo "Adding '${USER}' to the database superusers"
sudo su - postgres -c "createuser -s $USER"
echo "Creating a database named ${USER}"
createdb $USER

echo "To connect from pgAdmin or psql from the desktop, use the following:"
echo "host = '/var/run/postgresql'"
echo "port = 5432"
echo "user = $USER"
echo "database = $USER"
echo
echo "There is no password."
echo "If pgAdmin asks for a password, enter an empty string."
