FROM postgres:10
LABEL maintainer="M. Edward (Ed) Borasky <znmeb@znmeb.net>"

# Install PostGIS
RUN apt-get update \
  && apt-get install -qqy --no-install-recommends \
  ca-certificates \
  postgis \
  postgresql-10-postgis-2.4 \
  postgresql-10-postgis-2.4-scripts \
  postgresql-10-postgis-scripts \
  && apt-get clean

# 'postgres' Linux home directory
RUN mkdir -p /home/postgres \
  && usermod --shell /bin/bash --home /home/postgres --move-home postgres \
  && chown -R postgres:postgres /home/postgres

ARG CONTAINER_POSTGRES_PORT
ENV CONTAINER_POSTGRES_PORT=$CONTAINER_POSTGRES_PORT
ENV PGPORT=$CONTAINER_POSTGRES_PORT
ARG POSTGRES_PASSWORD
ENV POSTGRES_PASSWORD=$POSTGRES_PASSWORD
