#! /bin/bash

# define parameters
export DBOWNER=transportation-systems
export PGDATABASE=transportation-systems-main

echo "Installing R packages"
./01install-r-packages.R
echo "Creating a fresh database"
./02create-fresh-database.bash
echo "Checking input sha512 sums"
./03checksum-input-data.bash

for dataset in \
  20reference \
  22odot-crash-data \
  23passenger-census \
  24safety-hotline \
  25biketown \
  26origin-destination
do
  pushd ${dataset}
  nice -10 ./create-tables
  popd
done

# require a parameter to ignore the big one
if [ "$#" -eq 0 ]; then
  echo "Processing 'trimet_stop_events'"
  pushd 29trimet-stop-events
  nice -10 ./create-tables
  popd
fi
echo "Creating database backup"
./90create-database-backup.bash
