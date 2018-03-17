#! /bin/bash

docker exec -it -e LINES=$LINES -e COLUMNS=$COLUMNS -u dbsuper -w /home/dbsuper containers_postgis_1 /bin/bash
