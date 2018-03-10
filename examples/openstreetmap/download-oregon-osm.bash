#! /bin/bash

echo "Downloading the data"
wget -q -nc http://download.geofabrik.de/north-america/us/oregon-latest.osm.bz2
bunzip2 oregon-latest.osm.bz2
