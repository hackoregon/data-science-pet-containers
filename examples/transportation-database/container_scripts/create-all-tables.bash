#! /bin/bash

# define parameters
export DBOWNER=transportation-systems
export PGDATABASE=transportation-systems-main

./01install-r-packages.R
./02create-fresh-database.bash
./03checksum-input-data.bash

for dataset in \
  20trimet-shapefiles \
  21trimet-stop-events \
  22odot-crash-data \
  23passenger-census \
  24safety-hotline \
  25biketown
do
  pushd ${dataset}
  nice -10 ./create-tables
  popd
done

./90create-database-backup.bash
