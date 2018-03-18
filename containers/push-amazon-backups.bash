#! /bin/bash

ls -Altr Backups
docker cp Backups containers_amazon_1:/home/dbsuper
