#! /bin/bash

echo "Downloading the data"
rm -f oregon-latest*
wget  http://download.geofabrik.de/north-america/us/oregon-latest.osm.bz2
bunzip2 oregon-latest.osm.bz2
