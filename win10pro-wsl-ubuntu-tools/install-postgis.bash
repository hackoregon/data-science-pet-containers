#! /bin/bash

# more repositories
sudo cp pgdg.list.xenial /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

sudo apt-get update && sudo apt-get install -y --no-install-recommends \
  osm2pgsql \
  osmctools \
  osmium-tool \
  osmosis \
  postgis \
  postgresql-10 \
  postgresql-client-10 \
  postgresql-server-dev-10 \
  postgresql-10-postgis-2.4 \
  postgresql-10-postgis-2.4-scripts \
  postgresql-10-postgis-scripts \
  postgresql-10-pgrouting \
  postgresql-10-mysql-fdw \
  postgresql-10-ogr-fdw \
  postgresql-10-python3-multicorn \
  awscli \
  bash-completion \
  build-essential \
  bzip2 \
  ca-certificates \
  cmake \
  command-not-found \
  curl \
  expat \
  gdal-bin \
  geotiff-bin \
  git \
  less \
  libboost-dev \
  libboost-program-options-dev \
  libexpat1-dev \
  libgdal-dev \
  libgeotiff-dev \
  libpq-dev \
  libpqxx-dev \
  librasterlite2-dev \
  libspatialite-dev \
  libudunits2-dev \
  lynx \
  mdbtools-dev \
  nano \
  openssh-client \
  p7zip \
  postgresql-client-10 \
  proj-bin \
  python3-csvkit \
  rasterlite2-bin \
  spatialite-bin \
  tar \
  udunits-bin \
  unixodbc-dev \
  unrar-free \
  unzip \
  vim \
  wget \
&& apt-file update \
&& update-command-not-found
exit

# Install osm2pgrouting from source
COPY osm2pgrouting-from-source.bash /usr/local/src/
RUN bash /usr/local/src/osm2pgrouting-from-source.bash

# set up automatic restores
COPY Backups/* /home/postgres/Backups/
COPY Backups/restore-all.sh /docker-entrypoint-initdb.d/
COPY configure-git.bash /home/postgres/
RUN chown -R postgres:postgres /home/postgres \
  && chmod +x /home/postgres/*.bash \
  && chmod +x /docker-entrypoint-initdb.d/restore-all.sh
