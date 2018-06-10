#! /bin/bash

# define parameters
export BASE=https://lehd.ces.census.gov/data/lodes/LODES7
mkdir -p ~/Raw/LODES; pushd ~/Raw/LODES

if [ ! -e "lodes_or.sha256sum" ]
then 
  for state in or wa
  do

    echo "${state}_xwalk"
    wget -nc ${BASE}/${state}/${state}_xwalk.csv.gz
    gzip -dc ${state}_xwalk.csv.gz > ${state}_xwalk.csv

    for year in 2002 2003 2004 2005 2006 2007 2008 2009 \
    2010 2011 2012 2013 2014 2015
    do

      for segment in od_main od_aux wac_S000 rac_S000
      do

        folder=`echo ${segment} | sed 's;_.*$;;'`
        echo "${state} ${year} ${segment} ${folder}"
        wget -nc ${BASE}/${state}/${folder}/${state}_${segment}_JT00_${year}.csv.gz
        gzip -dc ${state}_${segment}_JT00_${year}.csv.gz > ${state}_${segment}_JT00_${year}.csv

      done # segment
    done # year
  
    wget -nc ${BASE}/${state}/lodes_${state}.sha256sum

  done # state
fi
echo "Checking sha256 sums"
for state in or wa
do
  sha256sum -c --ignore-missing lodes_${state}.sha256sum
done

popd
