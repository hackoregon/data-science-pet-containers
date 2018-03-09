-   [Data Science Pet Containers](#data-science-pet-containers)
    -   [Setting up](#setting-up)
    -   [Starting the services](#starting-the-services)
    -   [The PostGIS service](#the-postgis-service)
        -   [Using the command line](#using-the-command-line)
        -   [Setting up `git`](#setting-up-git)
        -   [Connecting to the service](#connecting-to-the-service)
        -   [Connecting with pgAdmin on the
            host](#connecting-with-pgadmin-on-the-host)
        -   [Using automatic database
            restores](#using-automatic-database-restores)
    -   [Miniconda](#miniconda)
        -   [Setting up `git`](#setting-up-git-1)
        -   [Installing packages](#installing-packages)
    -   [RStudio](#rstudio)
        -   [Setting up `git`](#setting-up-git-2)
        -   [Installing R packages](#installing-r-packages)
    -   [About the name](#about-the-name)

Data Science Pet Containers
===========================

M. Edward (Ed) Borasky <znmeb@znmeb.net>, 2018-03-08

Setting up
----------

1.  Clone this repository and
    `cd data-science-pet-containers/containers`.
2.  Define the environment variables.
    -   Copy the file `sample.env` to `.env`. For security reasons,
        `.env` is listed in `.gitignore`, so it ***won’t*** be checked
        into version control.
    -   Edit `.env`. The variables you need to define are
        -   `HOST_POSTGRES_PORT`: If you have PostgreSQL installed on
            your host, it’s probably listening on port 5432. The
            `postgis` service listens on port 5432 inside the Docker
            network, so you’ll need to map its port 5432 to another
            port. Set `HOST_POSTGRES_PORT` to the value you want; 5439
            is what I use.
        -   `POSTGRES_PASSWORD`: To connect to the `postgis` service,
            you need a user name and a password. The user name is the
            default, the database superuser `postgres`. Docker will set
            the password for the `postgres` user in the `postgis`
            service to the value of `POSTGRES_PASSWORD`.

    Here’s `sample.env`:

        # postgis container
        HOST_POSTGRES_PORT=5439
        POSTGRES_PASSWORD=some.string.you.can.remember.that.nobody.else.can.guess

Starting the services
---------------------

1.  Choose your version:

    -   `postgis.yml`: PostGIS only. If you’re doing all the analysis on
        the host and just want the PostGIS service, choose this. If
        you’re an experienced Linux command-line user, this image has a
        comprehensive collection of extract-transform-load (ETL) and GIS
        tools.
    -   `miniconda.yml`: PostGIS and Miniconda. Choose this if you want
        to run a Jupyter notebook server inside the Docker network.
    -   `rstudio.yml`: PostGIS and RStudio Server. Choose this if you
        want an RStudio Server inside the Docker network.

2.  Type `docker-compose -f <version> up -d --build`. Docker will
    build/rebuild the images and start the services.

The PostGIS service
-------------------

The `postgis` service is based on the official PostgreSQL image from the
Docker Store: <https://store.docker.com/images/postgres>. It is running

-   PostgreSQL 10,
-   PostGIS 2.4,
-   pgRouting 2.5, and
-   all of the foreign data wrappers that are available in a Debian
    `stretch` PostgreSQL server.

All three images acquire PostgreSQL and its accomplices from the
official PostgreSQL Global Development Group (PGDG) Debian repositories:
<https://www.postgresql.org/download/linux/debian/>.

### Using the command line

I’ve tried to provide a comprehensive command line experience. `Git`,
`curl`, `wget`, `lynx` and `vim` are there, as is most of the
command-line GIS stack (`gdal`, `proj`, `spatialite`, `rasterlite`,
`geotiff`, `osm2pgsql` and `osm2pgrouting`), and of course `psql`.

I’ve also included `python3-csvkit` for Excel, CSV and other text files,
`unixodbc` for ODBC connections and `mdbtools` for Microsoft Access
files. If you want to extend this image further, it is based on Debian
`stretch`.

There are two Linux accounts available, `root`, the Linux superuser, and
`postgres`, the database superuser. Type
`docker exec -it -u <account> containers_postgis_1 /bin/bash` and you’ll
be logged in.

### Setting up `git`

1.  Log in as `postgres` as described above.
2.  `cd /home/postgres`.
3.  Edit `configure-git.bash`. You’ll need to supply your email address
    and name.
4.  Enter `./configure-git.bash`.

To clone a repository, use its `https` URL. For a private repository,
you’ll need to authenticate when you clone. For a public one, you’ll
only have to authenticate if you want to push.

In either case, once you’ve authenticated, `git` will cache your
credentials for an hour. As you probably noticed, this timeout is
adjustable in `configure-git.bash`.

### Connecting to the service

-   From the host, connect to `localhost`, port `HOST_POSTGRES_PORT`.
-   Inside the Docker network, connect to `postgis`, port 5432.
-   In both cases, the username and maintenance database are `postgres`
    and the password is `POSTGRES_PASSWORD`.

### Connecting with pgAdmin on the host

If you’ve installed the EnterpriseDB PostgreSQL distribution, you
probably already have pgAdmin, although it may not be the latest
version. Here are the links if you want to install it without
PostgreSQL:

-   macOS installer: <https://www.pgadmin.org/download/pgadmin-4-macos/>
-   Windows: <https://www.pgadmin.org/download/pgadmin-4-windows/>

To connect to the `postgis` service on `localhost:HOST_POSTGRES_PORT`
with pgAdmin:

1.  Right-click on `Servers` and create a server. Give it any name you
    want.
2.  On the `Connection` tab, set the host to `localhost`, the port to
    `HOST_POSTGRES_PORT`, the maintenance database to `postgres`, the
    user name to `postgres` and the password to the value you set for
    `POSTGRES_PASSWORD`.
3.  Check the `Save password` box and press the `Save` button. `pgAdmin`
    will add the tree for the `postgis` service.

### Using automatic database restores

When the `postgis` service first starts, it initializes the database.
After that, it looks in a directory called
`/docker-entrypoint-initdb.d/` and restores any `.sql` or `sql.gz` files
it finds. Then it looks for `.sh` scripts and runs them. We use this to
restore databases automatically at startup.

To use this feature:

1.  For each database you want restored, create a file `<dbname>.backup`
    with either a pgAdmin `Backup` operation or with `pg_dump`. The file
    must be in [`pg_dump`
    format](https://www.postgresql.org/docs/current/static/app-pgdump.html).
2.  Copy the database backup files to
    `data-science-pet-containers/containers/Backups`. Note that
    `.gitignore` is set for `*.backup`, so these backup files won’t be
    version-controlled.
3.  Type `docker-compose -f postgis.yml build`.

Docker will copy the backup files into `/home/postgres/Backups` on the
`postgis` image, and place a script `restore-all.sh` in
`/docker-entrypoint-initdb.d/`. The first time the image runs,
`restore-all.sh` will restore all the `.backup` files it finds in
`/home/postgres/Backups`.

`restore-all.sh` creates a new database with the same name as the file.
For example, `passenger_census.backup` will be restored to a
freshly-created database called `passenger_census`. The new databases
will have the owner `postgres`.

Miniconda
---------

This service is based on the Anaconda, Inc. (formerly Continuum)
`miniconda3` image: <https://hub.docker.com/r/continuumio/miniconda3/>.
I’ve added a non-root user `jupyter` to avoid the security issues
associated with running Jupyter notebooks as “root”.

The `jupyter` user has a Conda environment, also called `jupyter`. To
keep the image size manageable, only the `jupyter` package is installed.

By default the Jupyter notebook server starts when Docker brings up the
service. Type `docker logs containers_miniconda_1`. You’ll see something
like this:

    ```
    $ docker logs containers_miniconda_1 
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

Browse to `localhost:8888` and copy/paste the token when the server asks
for it.

### Setting up `git`

1.  Edit `configure-git.bash`with the Jupyter notebook file editor.
    You’ll need to supply your email address and name.
2.  Open a new terminal using the `New -> Terminal` dropdown at the
    upper right of the `Home` tab.
3.  Enter `./configure-git.bash`.

To clone a repository, use its `https` URL. For a private repository,
you’ll need to authenticate when you clone. For a public one, you’ll
only have to authenticate if you want to push.

In either case, once you’ve authenticated, `git` will cache your
credentials for an hour. As you probably noticed, this timeout is
adjustable in `configure-git.bash`.

### Installing packages

As noted above, to keep the image size down, I’ve only provided a
Jupyter notebook server. To install packages:

1.  Open a new terminal using the `New -> Terminal` dropdown at the
    upper right of the `Home` tab.
2.  Enter `bash`. The terminal comes up initially in the `sh` shell,
    which is missing many command-line conveniences.
3.  Enter `source activate jupyter`.
4.  Use `conda search` to find packages in the Conda ecosystem, then
    install them with `conda install`. You can also install packages
    with `pip` if they’re not in the Conda repositories.

RStudio
-------

This service is based on the `rocker/rstudio` image from Docker Hub:
<https://hub.docker.com/r/rocker/rstudio/>. I’ve added header files so
that the R packages `RPostgres`, `odbc`, `sf` and `devtools` will
install from source, but there are no R packages besides those that ship
with `rocker/rstudio`.

Browse to `localhost:8787`. The user name and password are both
`rstudio`. ***Note that if you’re using Firefox, you’ll have to adjust a
setting to use the terminal feature.***

-   Go to `Tools -> Global Options -> Terminal`.
-   For Firefox, uncheck the `Connect with WebSockets` option.

### Setting up `git`

1.  Edit `configure-git.bash`. You’ll need to supply your email address
    and name.
2.  Open a new terminal and enter `./configure-git.bash`.

To clone a repository, use its `https` URL. For a private repository,
you’ll need to authenticate when you clone. For a public one, you’ll
only have to authenticate if you want to push.

In either case, once you’ve authenticated, `git` will cache your
credentials for an hour. As you probably noticed, this timeout is
adjustable in `configure-git.bash`.

### Installing R packages

As noted above, to keep the image size down, I’ve only installed header
files so that the R packages `RPostgres`, `odbc`, `sf` and `devtools`
will install. That covers the majority of use cases.

However, if you find an R package that won’t install because of missing
header or other Linux dependency, open an issue at
<https://github.com/hackoregon/data-science-pet-containers/issues/new>.

Most packages that have missing dependencies will list the name of the
Debian packages you need to install. If that’s the case, open a `root`
console with `docker exec -it -u root containers_rstudio_1 /bin/bash`.
Then type `apt install <package-name>`. After the Debian package is
installed, you should be able to install the R package.

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
