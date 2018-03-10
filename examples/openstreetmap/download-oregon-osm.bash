#! /bin/bash

echo "Downloading TriMet boundary"
rm -f tm_boundary*
wget https://developer.trimet.org/gis/data/tm_boundary.zip
unzip tm_boundary.zip
ogr2ogr -f GeoJSON -t_srs EPSG:4326 tm_boundary.geojson tm_boundary.shp -lco WRITE_BBOX=YES 
bboxraw=`head -n 4 tm_boundary.geojson | grep bbox | sed 's/"bbox": \[ //' | sed 's/ \].*$//'`
IFS=', ' read -r -a bbox <<< "$bboxraw"
echo "Bounding box = ${bbox[*]}"
echo "left bottom right top"
left=${bbox[0]}
bottom=${bbox[1]}
right=${bbox[2]}
top=${bbox[3]}

echo "Downloading Oregon OpenStreetMap data"
rm -f oregon-latest*
wget http://download.geofabrik.de/north-america/us/oregon-latest.osm.bz2
bunzip2 oregon-latest.osm.bz2

echo "Filtering down to TriMet bounding box"
rm -f trimet-latest*

# reference https://wiki.openstreetmap.org/wiki/Osmosis#Extracting_bounding_boxes
osmosis --read-xml enableDateParsing=no file=oregon-latest.osm \
  --bounding-box top=$top left=$left bottom=$bottom right=$right \
  --write-xml file=- > trimet-latest.osm
