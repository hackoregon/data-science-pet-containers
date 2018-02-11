Data Science Pet Containers
================
M. Edward (Ed) Borasky
2018-02-10

## Setup

1.  Make sure you have reliable power and internet bandwidth. The build
    phase does a fair amount of downloading. Install Docker hosting if
    you haven’t already - Docker Community Edition or its equivalent.
    You will need the `docker` and `docker-compose` executables in your
    `PATH`.
2.  Clone this repository and `cd
    data-science-pet-containers/containers`.
3.  Define the environment variables in a file called `.env`. Note that
    this file is in `.gitignore` and will ***not*** be
    version-controlled. The variables you need to define are

<!-- end list -->

  - HOST\_POSTGRES\_PORT: The `postgis` service listens on port 5432.
    Docker will map that port into this port on `localhost`.
  - POSTGRES\_PASSWORD: Docker will set the password for the `postgres`
    user in the `postgis` service to this value.
  - HOST\_PGADMIN\_PORT: The `pgadmin4` service listens on port 80.
    Docker will map that port into this port on `localhost`.
  - PGADMIN\_DEFAULT\_EMAIL: You log in to the `pgadmin4` web service
    with an email address and password. Docker will set the email
    address to this value.
  - PGADMIN\_DEFAULT\_PASSWORD: The password
  - HOST\_RSTUDIO\_PORT: The `rstudio` service listens on port 8787.
    Docker will map that port into this port on `localhost`.

Here’s a sample `.env` you can paste and edit to your liking:

    # postgis container
    HOST_POSTGRES_PORT=5439
    POSTGRES_PASSWORD=some.string.you.can.remember.that.nobody.else.can.guess
    
    # pgadmin4 container
    HOST_PGADMIN_PORT=8080
    PGADMIN_DEFAULT_EMAIL=znmeb@znmeb.net
    PGADMIN_DEFAULT_PASSWORD=some.string.you.can.remember.that.nobody.else.can.guess
    
    # rstudio server container
    HOST_RSTUDIO_PORT=8786

4.  Type `docker-compose build`. Wait. On my workstation (4 GHz 8 core,
    60 mbits/second download) it takes about 15 minutes. Docker will
    create a network called `containers_default` and build the images.
