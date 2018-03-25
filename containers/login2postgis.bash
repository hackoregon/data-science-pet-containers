#! /bin/bash

if [ "$#" -gt 0 ]
then
  docker exec -it -e LINES=$LINES -e COLUMNS=$COLUMNS -u ${1} -w /home/${1} containers_postgis_1 /bin/bash
else
  docker exec -it -e LINES=$LINES -e COLUMNS=$COLUMNS -u dbsuper -w /home/dbsuper containers_postgis_1 /bin/bash
fi
