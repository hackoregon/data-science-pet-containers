#! /bin/bash

if [ "$#" -gt 0 ]
then
  docker exec -it -e LINES=$(tput lines) -e COLUMNS=$(tput cols) -u ${1} containers_postgis_1 /bin/bash
else
  docker exec -it -e LINES=$(tput lines) -e COLUMNS=$(tput cols) -u dbsuper -w /home/dbsuper containers_postgis_1 /bin/bash
fi
