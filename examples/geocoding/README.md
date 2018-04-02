The Hack Oregon PostGIS Geocoder
================

## Setup

1.  Bring up the PostGIS container: `cd
    data-science-pet-containers/containers; docker-compose -f
    postgis.yml up -d --build`
2.  `cd data-science-pet-containers/examples/geocoding`

## Generating the database

Type `./run-from-linux.bash`. This will

1.  Copy the geocoder population scripts to `containers_postgis_1`.
2.  Run the geocoder population scripts. This takes some time.
3.  Copy the finished database backup and archive of the TIGER
    shapefiles back to `data-science-pet-containers/containers/Raw`.

## Blacklisting warning

If you run this process often enough, the Census Bureau will blacklist
you and you’ll get `403 Forbidden` errors trying to download the
shapefiles. So the first time you run this, assuming success, make sure
you keep backups of the result file `geocoder.backup` and the downloaded
shapefiles `tiger.zip`.

## Using the geocoder

1.  Connect to the database:
    
      - Inside the Docker network: host=`postgis`, port=5432,
        user=dbsuper, password=<POSTGRES_PASSWORD>
      - From the Docker host: host=`localhost`, port=5439, user=dbsuper,
        password=<POSTGRES_PASSWORD>
    
    where `<POSTGRES_PASSWORD>` is the value you set for that variable
    when you built `containers_postgis_1`.

2.  Run the following SQL. You can use this as a model for
    single-address geocoding.
    
        SELECT
          g.rating As r,
          ST_X(geomout) As lon,
          ST_Y(geomout) As lat,
          pprint_addy(addy) As paddress
        FROM
          geocode(
            '329 NE Couch St, Portland, OR 97232'
          ) As g;
        SELECT
          pprint_addy(addy),
          st_astext(geomout),
          rating
        FROM
          geocode_intersection(
            'Grand Ave', 'Couch St', 'OR', 'Portland'
          );

### Bulk geocoding

See the example at <https://postgis.net/docs/Geocode.html>.

## The host-side script

``` bash
#! /bin/bash

echo "Copying the code to the container"
docker cp geocoder_scripts containers_postgis_1:/usr/local/src/
docker exec -u root containers_postgis_1 \
  chown -R postgres:postgres /usr/local/src/geocoder_scripts
docker exec -u root containers_postgis_1 \
  chmod +x /usr/local/src/geocoder_scripts/create-geocoder-database.bash
echo "Populating the database - will take some time!"
echo ""
echo ""
docker exec -u postgres -w /usr/local/src/geocoder_scripts containers_postgis_1 \
  /usr/local/src/geocoder_scripts/create-geocoder-database.bash
echo "Retriving database backup"
docker cp containers_postgis_1:/gisdata/geocoder.backup ../../containers/Raw
echo "Retriving shapefile archive"
docker cp containers_postgis_1:/gisdata/tiger.zip ../../containers/Raw
echo "Retriving database population scripts"
docker cp containers_postgis_1:/gisdata/nation.bash ../../containers/Raw
docker cp containers_postgis_1:/gisdata/oregon.bash ../../containers/Raw
```
