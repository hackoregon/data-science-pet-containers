Re-owning a Database
================

## Situation

A team has given you a backup of a database in `pg_dump` custom format.
All the objects in it have `postgres` as the owner. You want to change
the ownership to the team’s account and make a compressed SQL backup.

## Steps

1.  Start up the PostGIS container: `cd
    data-science-pet-containers/containers; docker-compose -f
    postgis.yml up -d --build`.
2.  Download the backup file to
    `data-science-pet-containers/examples/reowning_a_database`.
3.  `cd data-science-pet-containers/examples/reowning_a_database`.
4.  Edit the file `linux-wrapper.bash`. The example I used to test was a
    file named `disaster.backup` from the `disaster-resilience` team.
    Change the definitions of `DB_SUPERUSER` and `DB_NAME` to match what
    you have.
5.  Enter `./linux-wrapper.bash`. The script will
      - Copy the original backup file and the `reown-demo.bash` script
        to the container with `docker cp`.
      - Execute the script in the container with `docker exec`.
      - Copy the new backup file from the container with `docker cp`.

## The scripts

### linux-wrapper.bash

``` bash
#! /bin/bash

export DB_SUPERUSER=disaster-resilience
echo "Will run as '$DB_SUPERUSER'; change 'DB_SUPERUSER' for a different user"
export DB_NAME=disaster
echo "Database name is '$DB_NAME'"
echo ""
echo ""

echo "Copying the demo script to the container"
docker cp reown-demo.bash containers_postgis_1:/home/$DB_SUPERUSER

echo "Copying the database backup to the container"
docker cp $DB_NAME.backup containers_postgis_1:/home/$DB_SUPERUSER

echo "Running the demo script in the container"
echo ""
echo ""
docker exec -it -u $DB_SUPERUSER -w /home/$DB_SUPERUSER -e DB_NAME=$DB_NAME -e USER=$DB_SUPERUSER \
  containers_postgis_1 /home/$DB_SUPERUSER/reown-demo.bash

echo "Retriving the compressed SQL backup"
docker cp containers_postgis_1:home/$DB_SUPERUSER/$DB_NAME.sql.gz .
ls -ltr $DB_NAME.*
```

### reown-demo.bash

``` bash
#! /bin/bash

echo "Dropping database; ignore the error if it doesn't exist"
dropdb $DB_NAME || true

echo "Creating a new database '$DB_NAME' owned by '$USER'"
createdb --owner $USER $DB_NAME

echo "Restoring the database as '$USER'"
pg_restore --dbname=$DB_NAME --no-owner $DB_NAME.backup

echo "Making a compressed SQL backup"
pg_dump -Fp -C -c --if-exists -d $DB_NAME | gzip -c > $DB_NAME.sql.gz
ls -ltr $DB_NAME.*
```
