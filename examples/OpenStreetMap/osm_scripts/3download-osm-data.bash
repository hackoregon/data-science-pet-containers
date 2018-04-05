#! /bin/bash

echo "Extracting TriMet service area bounding box"
bboxraw=`grep -e '"bbox":' tm_boundary.geojson | head -n 1 | sed 's/^.*"bbox": \[ //' | sed 's/ \].*$//' | sed 's/ //g'`
echo "Bounding box = $bboxraw"

echo "Downloading Oregon OpenStreetMap data"
rm -f oregon-latest*
wget http://download.geofabrik.de/north-america/us/oregon-latest.osm.pbf

echo "Filtering down to TriMet bounding box"
rm -f trimet-latest*
# reference https://github.com/pgRouting/osm2pgrouting/issues/221#issuecomment-372061947
osmconvert oregon-latest.osm.pbf \
  --verbose --drop-author --drop-version -b=$bboxraw --complex-ways \
  --out-osm -o=trimet-latest.osm
osmconvert oregon-latest.osm.pbf \
  --verbose -b=$bboxraw --complex-ways \
  --out-osm -o=trimet-latest-big.osm
du -sm * | sort -k 1 -n
cp *.pbf *.osm /home/dbsuper/Raw/
