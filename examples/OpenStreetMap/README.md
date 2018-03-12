Oregon OpenStreetMap Data
================
M. Edward (Ed) Borasky
2018-03-12

## Required resources

This example is a bit demanding. It runs in four phases:

1.  Creating a fresh database `osm_routing`.
2.  Loading TriMet GIS data into the database.
3.  Downloading the Oregon OpenStreetMap data and restricting the data
    to the TriMet service areas.
4.  Computing the routing data and loading it into the database.

The first three phases are simple and should run fine in a Docker
container. But the fourth phase, creating the `pgRouting` database of
the TriMet service area, requires a bit over 4 GB of RAM to run.

As a result, the fourth phase won’t run on my 8 GB Windows 10 Pro laptop
in Docker, which only allocates 2 GB of RAM to ***all*** the containers.
It should run with any Docker host big enough to allocate 5 GB of RAM to
the `postgis` container. It only requires the `postgis` container.

## Running the scripts

1.  Get a Docker host with enough RAM to run it.
2.  Bring up the `postgis` service with `docker-compose`.
3.  Log in to the container as `postgres`.
4.  Run the `1create-routing-database.bash` script. It will create a
    fresh `osm_routing` database with the `postgis`, `pgrouting` and
    `hstore` extensions.
5.  Run the `2load-trimet-data.bash` script. It will download the TriMet
    GIS shapefiles, convert them to GeoJSON and load them into the
    `osm_routing` data in schema `trimet_gis`.
6.  Run the script `3download-osm-data.bash`. It will download the
    latest Oregon OpenStreetMap data and create a file called
    `trimet-latest.osm`. This file contains only the data inside the
    bounding box of the TriMet service area.
7.  Run the script `4make-routing-database.bash`. As noted above, this
    requires over 4 GB of RAM. The script will
      - Create and populate three schemas, one for each mode: “cars”,
        “bicycles” and “pedestrian.” This part takes some time - about
        15 minutes for each mode on my workstation.
      - Create a `pg_dump` backup of the `osm_routing` database. The
        backup is currently about 736 megabytes.

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
