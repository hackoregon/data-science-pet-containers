#! /bin/bash

# define parameters
export DBOWNER=transportation-systems
export PGDATABASE=transportation-systems-main

export HERE=${PWD}
export OR=https://lehd.ces.census.gov/data/lodes/LODES7/or
export WA=https://lehd.ces.census.gov/data/lodes/LODES7/wa
mkdir -p ~/Raw/LODES; pushd ~/Raw/LODES

if [ ! -e "lodes_or.sha256sum" ]
then 
  echo "Downloading or_xwalk.csv.gz"
  wget -nc -q https://lehd.ces.census.gov/data/lodes/LODES7/or/or_xwalk.csv.gz
  echo "Decompressing or_xwalk.csv.gz"
  gzip -dc or_xwalk.csv.gz > or_xwalk.csv
  echo "Downloading wa_xwalk.csv.gz"
  wget -nc -q https://lehd.ces.census.gov/data/lodes/LODES7/wa/wa_xwalk.csv.gz
  echo "Decompressing wa_xwalk.csv.gz"
  gzip -dc wa_xwalk.csv.gz > wa_xwalk.csv
  for year in 2002 2003 2004 2005 2006 2007 2008 2009 \
    2010 2011 2012 2013 2014 2015
  do
    echo "Downloading or_od_main_JT00_${year}.csv.gz"
    wget -nc -q ${OR}/od/or_od_main_JT00_${year}.csv.gz
    echo "Decompressing or_od_main_JT00_${year}.csv.gz"
    gzip -dc or_od_main_JT00_${year}.csv.gz > or_od_main_JT00_${year}.csv

    echo "Downloading or_od_aux_JT00_${year}.csv.gz"
    wget -nc -q ${OR}/od/or_od_aux_JT00_${year}.csv.gz
    echo "Decompressing or_od_aux_JT00_${year}.csv.gz"
    gzip -dc or_od_aux_JT00_${year}.csv.gz > or_od_aux_JT00_${year}.csv

    echo "Downloading or_wac_S000_JT00_${year}.csv.gz"
    wget -nc -q ${OR}/wac/or_wac_S000_JT00_${year}.csv.gz
    echo "Decompressing or_wac_S000_JT00_${year}.csv.gz"
    gzip -dc or_wac_S000_JT00_${year}.csv.gz > or_wac_S000_JT00_${year}.csv

    echo "Downloading or_rac_S000_JT00_${year}.csv.gz"
    wget -nc -q ${OR}/rac/or_rac_S000_JT00_${year}.csv.gz
    echo "Decompressing or_rac_S000_JT00_${year}.csv.gz"
    gzip -dc or_rac_S000_JT00_${year}.csv.gz > or_rac_S000_JT00_${year}.csv

    echo "Downloading wa_rac_S000_JT00_${year}.csv.gz"
    wget -nc -q ${WA}/rac/wa_rac_S000_JT00_${year}.csv.gz
    echo "Decompressing wa_rac_S000_JT00_${year}.csv.gz"
    gzip -dc wa_rac_S000_JT00_${year}.csv.gz > wa_rac_S000_JT00_${year}.csv
  done
  wget -nc -q https://lehd.ces.census.gov/data/lodes/LODES7/or/lodes_or.sha256sum
  wget -nc -q https://lehd.ces.census.gov/data/lodes/LODES7/wa/lodes_wa.sha256sum
fi
echo "Checking sha256 sums"
sha256sum -c --ignore-missing lodes_or.sha256sum
sha256sum -c --ignore-missing lodes_wa.sha256sum

echo "Stacking xwalk"
cp or_xwalk.csv xwalk.csv
tail -q -n +2 wa_xwalk.csv >> xwalk.csv

echo "Stacking origin_destination"
head -q -n 1 *main*csv | head -n 1 > origin_destination.csv
grep -H "," or_od_main_JT00_20*.csv | \
  sed 's/^.*or_od_main_JT00_//' | \
  sed 's/.csv:/,/' | \
  grep -v geocode >> origin_destination.csv
grep -H "," or_od_aux_JT00_20*.csv | \
  sed 's/^.*or_od_aux_JT00_//' | \
  sed 's/.csv:/,/' | \
  grep -v geocode >> origin_destination.csv

echo "Stacking residence_area_characteristics"
head -q -n 1 *rac*csv | head -n 1 > residence_area_characteristics.csv
grep -H "," or_rac_S000_JT00_20*.csv | \
  sed 's/^.*or_rac_S000_JT00_//' | \
  sed 's/.csv:/,/' | \
  grep -v geocode >> residence_area_characteristics.csv
grep -H "," wa_rac_S000_JT00_20*.csv | \
  sed 's/^.*wa_rac_S000_JT00_//' | \
  sed 's/.csv:/,/' | \
  grep -v geocode >> residence_area_characteristics.csv

echo "Stacking workplace_area_characteristics"
head -q -n 1 *wac*csv | head -n 1 > workplace_area_characteristics.csv
grep -H "," or_wac_S000_JT00_20*.csv | \
  sed 's/^.*or_wac_S000_JT00_//' | \
  sed 's/.csv:/,/' | \
  grep -v geocode >> workplace_area_chawacteristics.csv

popd
