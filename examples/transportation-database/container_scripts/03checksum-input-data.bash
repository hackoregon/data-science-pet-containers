#! /bin/bash

# define parameters
export DBOWNER=transportation-systems
export PGDATABASE=transportation-systems-main

export SHA512SUMS=${PWD}/sha512sums
pushd ~/Raw
sha512sum -c "${SHA512SUMS}/passenger_census.csv.sha512sum"
sha512sum -c "${SHA512SUMS}/Portland_Fatal___Injury_Crashes_2004-2014_Decode.mdb.sha512sum"
sha512sum -c "${SHA512SUMS}/Safety_Hotline_Tickets.csv.sha512sum"
sha512sum -c "${SHA512SUMS}/scrapes.rar.sha512sum"
popd
