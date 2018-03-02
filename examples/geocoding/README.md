# Oregon Geocoder as a Docker image

## Linux hosting

### Prerequisites
* Docker Community Edition (stable): Docker version 17.12.0-ce (2017-12-27) or later. Don't use the "Edge" version; I don't test with it.
* docker-compose: docker-compose version 1.18.0 (2017-12-18) or later, and
* PostgreSQL 10 client (psql, pgadmin4, etc.) on your host if you want to access the container from the host. Don't use `pgadmin3` if you can avoid it; it's obsolete and not well-supported.
* Note: I am currently testing on an Arch Linux system.
  ```
  docker-compose version 1.18.0, build unknown
  Docker version 18.01.0-ce, build 03596f51b1
  ```

* Host disk space for persistence. The build process mounts two host directories as volumes inside containers. 
        
    1. `/d/gisdata` is mounted in the containers as `/gisdata`. This is where the database population scripts save the downloaded TIGER/Line® shapefiles. Note that if you run this a few times, the Census Bureau will blacklist your IP address. So make sure you back this area up somewhere. As long as you have all the data, the scripts will run correctly even if you're blacklisted.

        `/d/gisdata` is also where the scripts save the `pg_dump` of the geocoder database. This directory will have UID and GID 999, which corresponds to the `postgres` user and group in the containers. Don't change this!` `/data/gisdata` is currently about 1.6 GB. The `geocoder.backup` file is about 848 MB.

    2. `/d/pgdata` is mounted in the containers as `/var/lib/postgresql/data/pgdata`. This is where the containers keep their PostgreSQL data. This is also UID and GID 999. For the geocoders, this is easily recreated, either by re-running the scripts or by restoring `geocoder.backup` in `/data/gisdata`. But for other applications, you'll want to be careful not to corrupt it with host processes. `/d/pgdata` with just the Oregon geocoder database is currently about 2.7 GB.

### Buidling the database and the images
1. Clone this repository.
2. Open a terminal and type `cd data-science-pet-containers/oregon-geocoder`.
3. Set a password for the `postgres` database superuser. Type `export PGPASSWORD="yourpasswordgoeshere"`. 
4. Type `./make-images.bash`. It will take a while to run; it is downloading shapefiles, unpacking them and inserting the contents into the database. You can ignore errors and warnings.
5. When the data acquisition is complete you'll see something like
```
postgis-geocoder_1  | 2018-01-20 11:10:01.039 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
postgis-geocoder_1  | 2018-01-20 11:10:01.039 UTC [1] LOG:  listening on IPv6 address "::", port 5432
postgis-geocoder_1  | 2018-01-20 11:10:01.062 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
postgis-geocoder_1  | 2018-01-20 11:10:01.103 UTC [68] LOG:  database system was shut down at 2018-01-20 11:10:00 UTC
postgis-geocoder_1  | 2018-01-20 11:10:01.118 UTC [1] LOG:  database system is ready to accept connections
```

When those messages appear, type `CTRL-C` to stop the service. The script will then shut down the service.

At this point you have

1. `/d/gisdata/geocoder.backup` - the geocoder database suitable for `pg_restore`,
2. Downloaded shapefiles in `/d/gisdata/www2.census.gov/`,
3. A PostgreSQL / PostGIS database in `/d/pgdata`,
4. A Docker image: `postgis-geocoder`.  The image is the image the scripts used to download the shapefiles and populate the database. Thus it has copies of all the scripts. Both are about 467 MB.

### Running the geocoder
To start the service, type `docker-compose up -d`. `docker-compose` will start the service and you'll see `Creating docker_postgis_1 ... done
`

You'll be able to connect from the host to PostGIS in the container as `postgres` on host `localhost` port `5439` with the password you set above. Note that the port is ***5439*** to avoid conflicts with your host PostgreSQL service, which usually listens on port 5432.

Testing: type

```
export PGPASSWORD="yourpasswordgoeshere"
source env-postgis-geocoder
./test-geocoder.bash
```

You'll see the Hack Oregon headquarters geocoded! The second table is the geocode for the intersection of Couch Street and Grand Avenue.

```
Testing the geocoder - compare lon and lat with Google Maps
 r |        lon        |       lat        |              paddress               
---+-------------------+------------------+-------------------------------------
 0 | -122.662452348985 | 45.5237405800767 | 329 NE Couch St, Portland, OR 97232
(1 row)

             pprint_addy              |          st_astext           | rating 
--------------------------------------+------------------------------+--------
 101 NE Grand Ave, Portland, OR 97232 | POINT(-122.660702 45.523645) |      3
 100 NE Grand Ave, Portland, OR 97232 | POINT(-122.660702 45.523645) |      3
 98 NE Grand Ave, Portland, OR 97232  | POINT(-122.660702 45.523645) |      3
(3 rows)
```
