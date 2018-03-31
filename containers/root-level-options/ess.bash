#! /bin/bash

export ESS_VERSION=17.11
cd /usr/local/src
wget http://ess.r-project.org/downloads/ess/ess-$ESS_VERSION.tgz
tar xf ess-$ESS_VERSION.tgz \
cd ess-$ESS_VERSION \
make > /usr/local/src/ess.log 2>&1 \
make install >> /usr/local/src/ess.log 2>&1
