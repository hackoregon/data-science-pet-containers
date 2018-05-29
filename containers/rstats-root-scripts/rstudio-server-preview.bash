#! /bin/bash

cd /usr/local/src
wget -nc -q https://s3.amazonaws.com/rstudio-ide-build/server/debian9/x86_64/rstudio-server-stretch-1.2.637-amd64.deb
gdebi -n rstudio-server-stretch-1.2.637-amd64.deb
