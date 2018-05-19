#! /bin/bash

# define parameters
export DBOWNER=transportation-systems
export PGDATABASE=transportation-systems-main

pushd ~/Raw
echo "Unpacking the raw data archive"
rm -f trimet_stop_event*csv
/usr/bin/time unar -D scrapes.rar "trimet_stop_event*"
popd
