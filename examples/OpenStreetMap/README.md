Oregon OpenStreetMap Data
================
M. Edward (Ed) Borasky
2018-04-02

## Required resources

This example is a bit demanding. It runs in four phases:

1.  Creating a fresh database `osm_routing`.
2.  Loading TriMet GIS data into the database.
3.  Downloading the Oregon OpenStreetMap data and restricting the data
    to the TriMet service area.
4.  Computing the routing data and loading it into the database.

The first three phases are simple and should run fine in a Docker
container. But the fourth phase, creating the `pgRouting` database of
the TriMet service area, requires a bit over 4 GB of RAM to run.

As a result, the fourth phase won’t run on my 8 GB Windows 10 Pro laptop
in Docker, which only allocates 2 GB of RAM to ***all*** the containers.
It should run with any Docker host big enough to allocate 5 GB of RAM to
the `postgis` container; it does run in Docker on my 32 GB Linux
workstation. It only requires the `postgis` container.

## Setup

1.  Clone <https://github.com/hackoregon/data-science-pet-containers>.
2.  `cd data-science-pet-containers/containers`.
3.  `docker-compose -f postgis.yml up -d --build`. This will bring the
    `postgis` image up in a container. Note that there is no raw data
    input for this example; everything required is downloaded when the
    scripts run.

## Running

1.  `cd Projects/data-science-pet-containers/examples/OpenStreetMap`.
2.  `./run-from-linux.bash`. The script will copy the conversion scripts
    to the container, run the scripts, and copy the resulting database
    backup to `data-science-pet-containers/containers/Raw`.

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
