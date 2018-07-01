#! /bin/bash

# define parameters
export DBOWNER=transportation-systems
export PGDATABASE=transportation-systems-main

export SHA512SUMS=${PWD}/../sha512sums
pushd ~/Raw
echo "Unpacking the raw data archive"
rm -f trimet_stop_event*csv
/usr/bin/time unar -D scrapes.rar "trimet_stop_event*"
/usr/bin/time unar -D 'April 2018.rar' "trimet_stop_event*"
/usr/bin/time unar -D 'May 2018.rar' "trimet_stop_event*"
for i in trimet_stop_event*.csv
do
  sha512sum -c "${SHA512SUMS}/${i}.sha512sum"
  csvgrep -c ROUTE_NUMBER -r "^4$|^14$|^73$" ${i} > trimmed_${i}
done
popd
