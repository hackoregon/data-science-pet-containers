ODOT Crash Data Conversion
================

This example demonstrates how to convert a Microsoft Access database
(“mdb”) file to a PostgreSQL backup using R and PostgreSQL.

## Setup

1.  Clone <https://github.com/hackoregon/data-science-pet-containers>.
2.  `cd data-science-pet-containers/containers`.
3.  Copy the raw data file to
    `data-science-pet-containers/containers/Raw`.
4.  `docker-compose -f postgis.yml up -d --build`. This will copy the
    raw data to the `postgis` image and bring it up in a container.

## Running

1.  `cd Projects/data-science-pet-containers/examples/passenger_census`.

2.  `./run-from-linux.bash`. The script will copy the raw data and
    conversion scripts to the container, run the scripts, and copy the
    results to `data-science-pet-containers/containers/Raw`.
    
    This takes a bit of time to run, most of which is installing the R
    packages that do the conversion.
