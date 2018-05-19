#! /bin/bash

# define parameters
export DBOWNER=transportation-systems
export PGDATABASE=transportation-systems-main

export SHA512SUMS=${PWD}/../sha512sums
pushd ~/Raw
echo "Unpacking the raw data archive"
rm -f trimet_stop_event*csv
sha512sum -c ${SHA512SUMS}/scrapes.rar.sha512sum
/usr/bin/time unar -D scrapes.rar "trimet_stop_event*"
for i in trimet_stop_event*.csv
do
  sha512sum -c "${SHA512SUMS}/${i}.sha512sum"
done
popd
