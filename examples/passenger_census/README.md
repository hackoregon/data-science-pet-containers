Passenger Census Conversion
================

This example demonstrates how to convert a comma-separated value (“csv”)
file to a PostgreSQL backup using PostgreSQL.

## Setup

1.  Clone <https://github.com/hackoregon/data-science-pet-containers>.
2.  `cd data-science-pet-containers/containers`.
3.  Copy the raw data file to
    `data-science-pet-containers/containers/Raw`.
4.  `docker-compose -f postgis.yml up -d --build`. This will copy the
    raw data to the `postgis` image and bring it up in a container.

## Running

1.  `docker exec -it -u dbsuper -w /home/dbsuper containers_postgis_1
    /bin/bash`. You’ll be logged in to the `containers_postgis_1`
    container as the database superuser `dbsuper`.
2.  `./clone-me.bash`. This clones the project inside the container.
3.  `cd Projects/data-science-pet-containers/examples/passenger_census`.
4.  `./make_database_backups.bash`. When the script exits, type `exit`
    and you’ll be back on the host.

## Retrieving the resulting backup

`docker cp containers_postgis_1:/home/dbsuper/Backups .` This copies all
the files from `/home/dbsuper/Backups` in the container into `./Backups`
on the host.
