#! /bin/bash

cd /usr/local/src
rm -fr osm2pgrouting-*
curl -Ls https://github.com/pgRouting/osm2pgrouting/archive/v2.3.3.tar.gz | tar xzf -
cd osm2pgrouting-*
cmake -H. -Bbuild
cd build
make
make install
