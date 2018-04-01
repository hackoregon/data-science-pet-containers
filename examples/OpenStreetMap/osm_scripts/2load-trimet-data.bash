#! /bin/bash

export WHERE=https://developer.trimet.org/gis/data
psql -d osm_routing -c "DROP SCHEMA IF EXISTS trimet_gis CASCADE;"
psql -d osm_routing -c "CREATE SCHEMA trimet_gis;"
for table in tm_boundary tm_parkride tm_rail_lines tm_rail_stops tm_routes tm_stops tm_route_stops tm_tran_cen
do
  wget -nc -q $WHERE/$table.zip
  rm -fr $table; rm -f $table.geojson; mkdir $table; cd $table
  unzip ../$table.zip
  ogr2ogr -f PostgreSQL -t_srs EPSG:4326 -lco PRECISION=NO -nlt PROMOTE_TO_MULTI \
    -lco SCHEMA=trimet_gis PG:"dbname=osm_routing" $table.shp
  ogr2ogr -f GeoJSON -t_srs EPSG:4326 \
    ../$table.geojson $table.shp -lco WRITE_BBOX=YES
  cd ..
done
