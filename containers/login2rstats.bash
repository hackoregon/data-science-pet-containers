#! /bin/bash

if [ "$#" -gt 0 ]
then
  docker exec -it -e LINES=$(tput lines) -e COLUMNS=$(tput cols) -u ${1} containers_rstats_1 /bin/bash
else
  docker exec -it -e LINES=$(tput lines) -e COLUMNS=$(tput cols) -u rstudio -w /home/rstudio containers_rstats_1 /bin/bash
fi
