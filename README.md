-   [Data Science Pet Containers](#data-science-pet-containers)
    -   [Quick start](#quick-start)
    -   [Using the services](#using-the-services)
        -   [PostGIS and pgAdmin](#postgis-and-pgadmin)
            -   [PostGIS](#postgis)
            -   [pgAdmin](#pgadmin)
            -   [Automatic restores](#automatic-restores)
        -   [Jupyter](#jupyter)
        -   [RStudio](#rstudio)
    -   [Integration with host data
        volumes](#integration-with-host-data-volumes)
    -   [About the name](#about-the-name)

Data Science Pet Containers
===========================

M. Edward (Ed) Borasky <znmeb@znmeb.net>, 2018-02-12

Quick start
-----------

1.  Clone this repository and
    `cd data-science-pet-containers/containers`.
2.  Define the environment variables in a file called `.env`. Note that
    this file is in `.gitignore` and will ***not*** be
    version-controlled. The variables you need to define are

    -   HOST\_POSTGRES\_PORT: The `postgis` service listens on
        port 5432. Docker will map that port into this port on
        `localhost`.
    -   POSTGRES\_PASSWORD: Docker will set the password for the
        `postgres` user in the `postgis` service to this value.
    -   HOST\_PGADMIN\_PORT: The `pgadmin4` service listens on port 80.
        Docker will map that port into this port on `localhost`.
    -   PGADMIN\_DEFAULT\_EMAIL: You log in to the `pgadmin4` web
        service with an email address and password. Docker will set the
        email address to this value.
    -   PGADMIN\_DEFAULT\_PASSWORD: The password
    -   HOST\_RSTUDIO\_PORT: The `rstudio` service listens on port 8787.
        Docker will map that port into this port on `localhost`.

    Here’s a sample `.env` you can copy / paste and edit to your liking:

        # postgis container
        HOST_POSTGRES_PORT=5439
        POSTGRES_PASSWORD=some.string.you.can.remember.that.nobody.else.can.guess

        # pgadmin4 container
        HOST_PGADMIN_PORT=8080
        PGADMIN_DEFAULT_EMAIL=znmeb@znmeb.net
        PGADMIN_DEFAULT_PASSWORD=some.string.you.can.remember.that.nobody.else.can.guess

        # rstudio server container
        HOST_RSTUDIO_PORT=8786

3.  Choose your version:

-   `small.yml`: PostGIS and pgAdmin only
-   `medium.yml`: PostGIS, pgAdmin, and Jupyter
-   `large.yml`: PostGIS, pgAdmin, Jupyter, and RStudio

1.  Type `docker-compose -f <version> -d --build`. Docker will
    build/rebuild the images and start the services.

Using the services
------------------

### PostGIS and pgAdmin

#### PostGIS

The `postgis` service is based on the official PostgreSQL image from the
Docker Store: <https://store.docker.com/images/postgres>. It is running
PostgreSQL 10, PostGIS 2.4, pgRouting and all of the foreign data
wrappers that are available in a Debian PostgreSQL server.

Inside the Docker network it can be accessed as host `postgis` on port
`5432`. Outside the network, it’s on `localhost` at port
`HOST_POSTGRES_PORT`. Note that all of these images except `pgadmin4`
acquire PostgreSQL and its accomplices from the official PostgreSQL
Debian repositories:
<https://www.postgresql.org/download/linux/debian/>.

#### pgAdmin

pgAdmin4 is available in two forms - as a desktop application and as a
web application. This service is the web application. *Note that it can
only access PostgreSQL services inside the network*.

The pgAdmin4 service is based on an experimental image:
<https://hub.docker.com/r/dpage/pgadmin4/>. The Dockerfile is here:
<https://github.com/postgres/pgadmin4/blob/master/pkg/docker/Dockerfile>.
Unlike the other images, it’s based on CentOS rather than Debian. If
this service proves useful I can build a new one based on Debian for
consistency.

To use pgAdmin, browse to port `HOST_PGADMIN_PORT` on `localhost`. It
will grind for a while, then give you a login form. The email address is
the one you set in `.env` for `PGADMIN_DEFAULT_EMAIL` and the password
is the one you set for `PGADMIN_DEFAULT_PASSWORD`.

After you log in, it will grind for a while again; this only happens the
first time. Then you’ll get the `pgAdmin` tree on the left. Right-click
on `Servers` and create a server.

Give it any name you want. Then on the `Connection` tab, set the host to
`postgis`, the port to `5432`, the maintenance database to `postgres`,
the user name to `postgres` and the password to the value you set for
`POSTGRES_PASSWORD`. Check the `Save password` box and press the `Save`
button. pgAdmin will add the tree for the `postgis` service.

#### Automatic restores

When the `postgis` service first starts, it initializes the database.
After that, it looks in a directory called
`/docker-entrypoint-initdb.d/` and restores any `.sql` or `sql.gz` files
it finds. Then it looks for `.sh` scripts and runs them.

We use this to restore databases as follows:

1.  For any database you want restored, create a file `<dbname>.backup`
    with either a pgAdmin `Backup` operation or with `pg_dump`. The file
    must be in [`pg_dump`
    format](https://www.postgresql.org/docs/current/static/app-pgdump.html).
2.  Before running `docker-compose`, copy those backup files into
    `data-science-pet-containers/containers/Backups`. Note that
    `.gitignore` is set, so these backup files won’t be
    version-controlled.
3.  At build time, Docker copies the backup files into
    `/home/postgres/Backups` on the image. And it places a script
    `restore-all.sh` in `/docker-entrypoint-initdb.d/`.
4.  The first time the image runs, `restore-all.sh` will restore all the
    `.backup` files it finds in `/home/postgres/Backups`.

### Jupyter

This service is based on the Anaconda, Inc. (formerly Continuum)
`miniconda3` image: <https://hub.docker.com/r/continuumio/miniconda3/>.
I’ve added a non-root user `jupyter` and created a Conda environment
also named `jupyter` in its home directory. I’ve only put `jupyter` and
`psycopg2` in the `jupyter` environment for now. The `vim` editor is
also available.

By default the Jupyter notebook server starts when Docker brings up the
service. Type `docker logs containers_jupyter_1`. You’ll see something
like this:

    ```
    $ docker logs containers_jupyter_1 
    [I 02:40:47.554 NotebookApp] Writing notebook server cookie secret to /home/jupyter/.local/share/jupyter/runtime/notebook_cookie_secret
    [I 02:40:47.877 NotebookApp] Serving notebooks from local directory: /home/jupyter
    [I 02:40:47.877 NotebookApp] 0 active kernels
    [I 02:40:47.877 NotebookApp] The Jupyter Notebook is running at:
    [I 02:40:47.877 NotebookApp] http://0.0.0.0:8888/?token=865963175cdf86fd8fb6c98a6ef880803cb9f1ef6cf10960
    [I 02:40:47.877 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
    [C 02:40:47.877 NotebookApp] 

    Copy/paste this URL into your browser when you connect for the first time,
    to login with a token:
        http://0.0.0.0:8888/?token=865963175cdf86fd8fb6c98a6ef880803cb9f1ef6cf10960
    ```

That link is where you want to point your browser. Or you can just
browse to `localhost:8888` and paste the token when it asks for it.

The Jupyter “New Terminal” works, but the terminal is coming up in `sh`
instead of `bash` for some reason. So if you use the terminal, type
`bash; source activate jupyter` to get something usable.

### RStudio

This service is based on the `rocker/rstudio` image from Docker Hub:
<https://hub.docker.com/r/rocker/rstudio/>. I’ve added some database
connectivity tools and the `vim` editor.

Browse to `localhost` on `HOST_RSTUDIO_PORT`. The user name and password
are both `rstudio`. Note that if you’re using Firefox, you’ll have to
adjust a setting to use the terminal feature. Go to
`Tools -> Global Options -> Terminal`. For Firefox, you need to uncheck
the `Connect with WebSockets` option. Other browsers I’ve tried,
Microsoft Edge and Chromium, don’t need this.

Integration with host data volumes
----------------------------------

TBD

About the name
--------------

This all started with an infamous “cattle, not pets” blog post. For some
history, see
<http://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/>.
In the Red Hat / Kubernetes / OpenShift universe, it’s common for people
to have a workstation that’s essentially a Docker / Kubernetes host with
all the actual work being done in containers. See
<https://rhelblog.redhat.com/2016/06/08/in-defense-of-the-pet-container-part-1-prelude-the-only-constant-is-complexity/>
and
<https://www.projectatomic.io/blog/2018/02/fedora-atomic-workstation/>.

So - pet containers for data scientists.
