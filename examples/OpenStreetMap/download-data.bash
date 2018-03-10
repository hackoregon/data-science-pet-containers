#! /bin/bash

echo "Downloading TriMet boundary"
rm -fr tm_boundary*
wget https://developer.trimet.org/gis/data/tm_boundary.zip
mkdir -p tm_boundary
cd tm_boundary
unzip ../tm_boundary.zip

echo "Converting shapefile to GeoJSON with bounding box"
ogr2ogr -f GeoJSON -t_srs EPSG:4326 ../tm_boundary.geojson tm_boundary.shp -lco WRITE_BBOX=YES 
cd ..
bboxraw=`grep -e '"bbox":' tm_boundary.geojson | head -n 1 | sed 's/"bbox": \[ //' | sed 's/ \].*$//' | sed 's/ //g'`
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
du -sh *
