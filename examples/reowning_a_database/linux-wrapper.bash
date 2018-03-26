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
