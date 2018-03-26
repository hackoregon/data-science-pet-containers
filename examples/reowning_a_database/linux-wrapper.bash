#! /bin/bash

echo "Copying the demo script to the container"
docker cp reown-demo.bash containers_postgis_1:/home/disaster-resilience

echo "Copying the database backup to the container"
docker cp disaster.backup containers_postgis_1:/home/disaster-resilience

echo "Logging in to the container"
docker exec -it -e LINES=$(tput lines) -e COLUMNS=$(tput cols) \
  -u disaster-resilience -w /home/disaster-resilience \
  containers_postgis_1 /bin/bash

echo "Retriving the compressed SQL backup"
docker cp containers_postgis_1:home/disaster-resilience/disaster.sql.gz .
ls -ltr
