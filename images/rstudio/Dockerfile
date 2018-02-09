FROM rocker/rstudio:latest
LABEL maintainer="M. Edward (Ed) Borasky <znmeb@znmeb.net>"

# add the MDB and ODBC tools
RUN apt-get update \
  && apt-get install -qqy --no-install-recommends \
  gnupg \
  mdbtools \
  mdbtools-dev \
  unixodbc-dev \
  && apt-get clean

# add PostgreSQL client tools
RUN mkdir -p /etc/apt/sources.list.d/
COPY pgdg.list /etc/apt/sources.list.d/
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && apt-get update \
  && apt-get install -qqy --no-install-recommends \
  libpq-dev \
  postgresql-client-10 \
  && apt-get clean

# install the R packages
RUN R -e 'install.packages("Hmisc", quiet = TRUE)' \
  && R -e 'install.packages("RPostgreSQL", quiet = TRUE)' \
  && R -e 'install.packages("RPostgres", quiet = TRUE)' \
  && R -e 'install.packages("RSQLite", quiet = TRUE)' \
  && R -e 'install.packages("odbc", quiet = TRUE)'
