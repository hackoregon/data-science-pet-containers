#! /bin/bash

# go to Raw
pushd ../../containers/Raw

# data source: https://www.census.gov/geo/maps-data/data/tiger-data.html
for i in 2010 2011
do
  rm -fr ${i}*
  wget https://www2.census.gov/geo/tiger/TIGER_DP/${i}ACS/${i}_ACS_5YR_BG_41.gdb.zip
  unzip ${i}_ACS_5YR_BG_41.gdb.zip
  ogr2ogr -f SQLite -overwrite ${i}_ACS_5YR_BG_OREGON.sqlite ${i}_ACS_5YR_BG_41_OREGON.gdb
done

for i in 2012 2013 2014 2015 2016
do
  rm -fr ACS_${i}*
  wget https://www2.census.gov/geo/tiger/TIGER_DP/${i}ACS/ACS_${i}_5YR_BG_41.gdb.zip
  unzip ACS_${i}_5YR_BG_41.gdb.zip
  ogr2ogr -f SQLite -overwrite ACS_${i}_5YR_BG_OREGON.sqlite ACS_${i}_5YR_BG_41_OREGON.gdb
done

popd
