#! /bin/bash

# define parameters
export DBOWNER=transportation-systems
export PGDATABASE=transportation-systems-main

export SHA512SUMS=${PWD}/sha512sums
pushd ~/Raw
sha512sum -c ${SHA512SUMS}/*.sha512sum
popd
