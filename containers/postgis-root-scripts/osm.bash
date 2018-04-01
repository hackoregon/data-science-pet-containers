#! /bin/bash

if [ ! -e /usr/bin/osmosis ]
then
  apt-get update
  apt-get install -qqy --no-install-recommends \
    osm2pgsql \
    osmctools \
    osmium-tool \
    osmosis
  apt-get clean \
  apt-file update \
  update-command-not-found
fi

if [ ! -e /usr/local/bin/osm2pgrouting ]
then
  cd /usr/local/src
  rm -fr osm2pgrouting-*
  curl -Ls https://github.com/pgRouting/osm2pgrouting/archive/v2.3.3.tar.gz | tar xzf -
  cd osm2pgrouting-*
  cmake -H. -Bbuild
  cd build
  make
  make install
fi
