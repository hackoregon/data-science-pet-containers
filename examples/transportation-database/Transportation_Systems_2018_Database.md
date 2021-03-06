Transportation Systems 2018 Database
================

## Setup

1.  Docker hosting: you will need a Linux Docker host capable of giving
    a container 6 GB of RAM without locking up.
2.  Raw data files: you will need to create a directory `~/Raw` and
    download the raw data files into it from the Transportation Systems
    master location. The required files are
      - passenger\_census.csv
      - scrapes.rar
      - Portland\_Fatal\_\_\_Injury\_Crashes\_2004-2014\_Decode.mdb
      - Safety\_Hotline\_Tickets.csv

Please open an issue at
<https://github.com/hackoregon/data-science-pet-containers/issues/new>
if you have different requirements.

## Operation

1.  Clone this repository and `cd
    data-science-pet-containers/containers`.
2.  Make sure there are no extraneous files in `Raw` or `Backups`. The
    script copies the required inputs from `~/Raw` to the container at
    run time and copies the resulting backup and its `sha512sum`
    checksum file from the container to `~/Raw` when it is completed.
3.  `docker-compose -f postgis.yml up -d --build`. This will build the
    PostGIS image if necessary and start it up in a container.
4.  `cd data-science-pet-containers/examples/transportation-database`.
5.  `./run-from-linux.bash`.

This takes a long time. The two biggest portions are installing the R
packages used for some of the processing and the creation of the
`trimet_stop_events` table for the TriMet congestion analysis.

When it’s done, you’ll have a compressed backup file
`transportation-systems-main.sql.gz` and its `sha512sum` checksum file
`transportation-systems-main.sql.gz.sha512sum` in `~/Raw`.
