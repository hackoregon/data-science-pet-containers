Oregon OpenStreetMap Data
================
M. Edward (Ed) Borasky
2018-03-10

## Required resources

This example is a bit demanding. It runs in two phases:

1.  Downloading and preparing the OpenStreetMap data.
2.  Populating and backing up a database.

The first phase should run fine in a Docker container. But the second
phase, creating a `pgRouting` database of the TriMet service area,
requires a bit over 4 GB of RAM to run.

As a result, the second phase won’t run on my 8 GB laptop in Docker,
which only allocates 2 GB of RAM to ***all*** the containers. It should
run with any Docker host big enough to allocate 5 GB of RAM to the
`postgis` container. It only requires the `postgis` container.

## Running the scripts

1.  Get a Docker host with enough RAM to run it.
2.  Bring up the `postgis` service with `docker-compose`.
3.  Log in to the container as `postgres`.
4.  Run the `download-data.bash` script. It will
      - Download the TriMet boundary shapefile and convert it to
        GeoJSON.
      - Extract the bounding box from the GeoJSON.
      - Download the most recent OpenStreetMap dataset for Oregon. This
        appears to be the smallest dataset that includes the Portland
        metro area.
      - Create a dataset with just the data inside the bounding box.
5.  Run the `make-routing-database.bash` script. As noted above, this
    requires over 4 GB of RAM. The script will
      - Create a database `osm_routing`.
      - Create the `postgis`, `pgrouting` and `hstore` extensions in the
        database.
      - Create and populate three schemas, one for each mode: “cars”,
        “bicycles” and “pedestrian.” This part takes some time - about
        15 minutes for each mode on my workstation.
      - Create a `pg_dump` backup of the database. The backup is
        currently about 736 megabytes.

## References

  - Obe, Regina, and Hsu, Leo (2017) *pgRouting: A Practical Guide*,
    Locate Press, ISBN 978-0989421737,
    <https://locatepress.com/pgrouting>
  - TriMet Developer Resources - Geospatial Data:
    <https://developer.trimet.org/gis/>
  - OpenStreetMap data download for Oregon:
    <http://download.geofabrik.de/north-america/us/oregon.html>
  - osmconvert: <https://wiki.openstreetmap.org/wiki/Osmconvert>
  - osm2pgrouting: <https://github.com/pgRouting/osm2pgrouting>
