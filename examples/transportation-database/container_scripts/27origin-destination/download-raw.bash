#! /bin/bash

# define parameters
export DBOWNER=transportation-systems
export PGDATABASE=transportation-systems-main

export HERE=${PWD}
export WHERE=https://lehd.ces.census.gov/data/lodes/LODES7/or/od
pushd ~/Raw

if [ ! -e "lodes_or.sha256sum" ]
then 
  echo "Downloading or_xwalk.csv.gz"
  wget -nc -q https://lehd.ces.census.gov/data/lodes/LODES7/or/or_xwalk.csv.gz
  echo "Decompressing or_xwalk.csv.gz"
  gzip -dc or_xwalk.csv.gz > or_xwalk.csv
  for year in 2002 2003 2004 2005 2006 2007 2008 2009 \
    2010 2011 2012 2013 2014 2015
  do
    echo "Downloading or_od_main_JT00_${year}.csv.gz"
    wget -nc -q ${WHERE}/or_od_main_JT00_${year}.csv.gz
    echo "Decompressing or_od_main_JT00_${year}.csv.gz"
    gzip -dc or_od_main_JT00_${year}.csv.gz > or_od_main_JT00_${year}.csv
  done
  wget -nc -q https://lehd.ces.census.gov/data/lodes/LODES7/or/lodes_or.sha256sum
fi
echo "Checking sha256 sums"
sha256sum -c --ignore-missing lodes_or.sha256sum

echo "Stacking the years"
cp ${HERE}/header origin_destination.csv
grep -H "," or_od_main_JT00_20*.csv | \
  sed 's/^.*or_od_main_JT00_//' | \
  sed 's/.csv:/,/' | \
  grep -v geocode >> origin_destination.csv
popd
