#! /bin/bash

ls -Altr Backups
docker cp containers_postgis_1:/home/dbsuper/Backups .
ls -Altr Backups
