#! /bin/bash

docker exec -it -e LINES=$(tput lines) -e COLUMNS=$(tput cols) -u dbsuper -w /home/dbsuper containers_amazon_1 /bin/bash
