Re-owning a Database
================

## Situation

The `disaster-resilience` team has given you a backup of a database in
`pg_dump` custom format. All the objects in it have `postgres` as an
owner. You want to change the ownership to `disaster-resilience` and
make a compressed SQL backup.

## Steps

1.  Download the backup file to
    `data-science-pet-containers/containers/Raw`. Although it’s a backup
    file, you don’t want it automatically restored, so you place it in
    the directory for raw data.

2.  `cd data-science-pet-containers/containers`. Bring up the
    `containers_postgis_1` container with the `--build` option:
    `docker-compose -f postgis.yml up -d --build`. This will copy all
    the files in `Raw` to the `/home/dbsuper/Raw` on the image and
    they’ll be there in the container.

3.  Log in as the target new owner for the database -
    `disaster-resilience`. This is a database superuser. `docker exec
    -it -u disaster-resilience containers_postgis_1 /bin/bash`.

4.  Check to see that the backup file is there:
    
        disaster-resilience@0966fc6263f4:~$ ls -l /home/dbsuper/Raw/
        total 305964
        -rw-r--r-- 1 dbsuper dbsuper 145395162 Mar 25 18:53 disaster.backup
        -rw-r--r-- 1 dbsuper dbsuper  71781939 Mar 20 06:09 passenger_census.csv
        -rw-r--r-- 1 dbsuper dbsuper  96129024 Mar 20 06:09 Portland_Fatal___Injury_Crashes_2004-2014_Decode.mdb

5.  Create and restore the database
    
        createdb --owner disaster-resilience disaster
        pg_restore --dbname=disaster --no-owner /home/dbsuper/Raw/disaster.backup

6.  Check that it worked with `psql`:
    
        disaster-resilience@0966fc6263f4:~$ psql --dbname=disaster
        psql (9.6.8)
        Type "help" for help.
        
        disaster=# 
    
    At the `#` prompt enter `\d`:
    
    ``` 
                                            List of relations
     Schema |                          Name                          |   Type   |        Owner        
    --------+--------------------------------------------------------+----------+---------------------
     public | building_footprints                                    | table    | disaster-resilience
     public | building_footprints_objectid_seq                       | sequence | disaster-resilience
     public | electrical_transmission_structures                     | table    | disaster-resilience
     public | electrical_transmission_structures_objectid_seq        | sequence | disaster-resilience
    
     [snip]
    
     :
    ```
    
    Page through the listing with the space bar.
    
        (49 rows)
        
        (END)
    
    Press `q` to exit the pager. `\q` to exit `psql`.

7.  Make a compressed SQL backup:
    
        pg_dump -Fp -C -c --if-exists -d disaster \
        | gzip -c > disaster.sql.gz
        ls -l
    
    When it’s done you’ll see
    
        total 143540
        -rw-r--r-- 1 disaster-resilience disaster-resilience 146984849 Mar 26 02:56 disaster.sql.gz
    
    Exit the container with `exit`.

8.  Copy the backup file from the container to the
        host:
    
        docker cp containers_postgis_1:/home/disaster-resilience/disaster.sql.gz .
        ls -l
