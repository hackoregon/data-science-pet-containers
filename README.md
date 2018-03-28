-   [Data Science Pet Containers](#data-science-pet-containers)
    -   [Overview](#overview)
        -   [About the examples](#about-the-examples)
    -   [Quick start](#quick-start)
    -   [Detailed setup](#detailed-setup)
        -   [About `DB_USERS_TO_CREATE`](#about-db_users_to_create)
    -   [Starting the services](#starting-the-services)
    -   [The PostGIS service](#the-postgis-service)
        -   [Using the command line](#using-the-command-line)
        -   [Linux host convenience
            scripts](#linux-host-convenience-scripts)
        -   [Virtualenvwrapper](#virtualenvwrapper)
        -   [Setting up `git`](#setting-up-git)
        -   [Connecting to the service](#connecting-to-the-service)
        -   [Connecting with pgAdmin on the
            host](#connecting-with-pgadmin-on-the-host)
        -   [Using automatic database
            restores](#using-automatic-database-restores)
        -   [The `Raw` directory](#the-raw-directory)
    -   [Jupyter](#jupyter)
        -   [Setting up `git`](#setting-up-git-1)
        -   [Installing packages](#installing-packages)
        -   [Connecting to the `postgis`
            service](#connecting-to-the-postgis-service)
        -   [Creating a Cookiecutter data science
            project](#creating-a-cookiecutter-data-science-project)
    -   [Rstats](#rstats)
        -   [Setting up `git`](#setting-up-git-2)
        -   [Installing R packages](#installing-r-packages)
        -   [Connecting to the `postgis`
            service](#connecting-to-the-postgis-service-1)
    -   [Amazon](#amazon)
    -   [About the name](#about-the-name)

Data Science Pet Containers
===========================

M. Edward (Ed) Borasky <znmeb@znmeb.net>, 2018-03-26

Overview
--------

Data Science Pet Containers comprise a collection of open-source
software for all phases of the data science workflow, from ingestion of
raw data through visualization, exploration, analysis and reporting. We
provide the following tools:

-   PostgreSQL / PostGIS / pgRouting: an industrial strength relational
    database management system with geographic information systems (GIS)
    extensions,
-   Anaconda Python tools, including a Jupyter notebook server, and
-   R language tools, including RStudio® Server.

As the name implies, the software is distributed via Docker. The user
simply clones a Git repository and uses the command `docker-compose up`
to bring up the services.

The stack that you will use to build and run the Docker images is comprised of the following:

- Windows 10 Pro
- Hyper-V Virtualization
- Windows Subsystem for Linux
- Ubuntu image for WSL

After you have installed these you should be able build and run the Docker images inside of your Ubuntu virtual machine that runs on Hyper-V and Windows Subsystem for Linux. On a Windows 10 Pro machine, you must ensure that the Hyper-V and Windows Subsystem for Linux features are enabled first. See [win10pro-wsl-ubuntu-tools instructions](win10pro-wsl-ubuntu-tools/README.md) for detailed instructions on how to install and configure this stack.

Why do it this way?

-   Provide a standardized common working environment for data
    scientists and DevOps engineers at Hack Oregon. We want to build
    using the same tools we’ll use for deployment as much as possible.
-   Deliver advanced open source technologies to Windows and MacOS
    desktops and laptops. While there are “native” installers for most
    of these tools, some are readily available for and only heavily
    tested on Linux.
-   Isolation: for the most part, software running in containers is
    contained. It interacts with the desktop / laptop user through
    well-defined mechanisms, often as a web server.

### About the examples

I’ve coded up some examples of how I’ve used this toolset for Hack
Oregon. They’re in `data-science-pet-containers/examples`. Those that
require host-side operations mostly use Bash for scripting, and they
work on a Linux host, including Windows 10 Pro Windows Subsystem for
Linux (WSL) Ubuntu.

Quick start
-----------

1.  Clone this repository and
    `cd data-science-pet-containers/containers`.
2.  Copy `sample.env` to `.env`. Edit `.env` and change the
    `POSTGRES_PASSWORD`. You don’t need to change the other values.
3.  Copy any PostgreSQL database backups you want restored to
    `data-science-pet-containers/containers/Backups`. Copy any raw data
    files you want on the image to
    `data-science-pet-containers/containers/Raw`.
4.  `docker-compose -f postgis.yml up -d --build`. The first time you
    run this, it will take some time. Once the image is built and the
    databases restored, it will be faster.

    When it’s done you’ll see

        Successfully tagged postgis:latest
        Creating containers_postgis_1 ... done

5.  Type `docker logs -f containers_postgis_1` to verify that the
    restores worked and the service is listening.

        PostgreSQL init process complete; ready for start up.

        LOG:  database system was shut down at 2018-03-18 05:19:22 UTC
        LOG:  MultiXact member wraparound protections are now enabled
        LOG:  database system is ready to accept connections
        LOG:  autovacuum launcher started

    Type `CTL-C` to stop following the container log.

6.  Connect to the container from the host: user name is `postgres`,
    host is `localhost`, port is the value of `HOST_POSTGRES_PORT`,
    usually 5439, and password is the value of `POSTGRES_PASSWORD`. You
    can connect with any client that uses the PostgreSQL protocol
    including pgAdmin and QGIS.

To stop the service, type `docker-compose -f postgis.yml stop`. To start
it back up again, `docker-compose -f postgis.yml start`.

The container and its filesystem will persist across host reboots. To
destroy them, type `docker-compose -f postgis.yml down`.

Detailed setup
--------------

1.  Clone this repository and
    `cd data-science-pet-containers/containers`.
2.  Define the environment variables:
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
        -   `DB_USERS_TO_CREATE`: When the `postgis` service first comes
            up, the users in this list are created in the database. If
            you’re working on the 2018 Hack Oregon projects, there’s no
            reason to change this.

Here’s `sample.env`:

    # postgis container
    HOST_POSTGRES_PORT=5439
    POSTGRES_PASSWORD=some.string.you.can.remember.that.nobody.else.can.guess
    DB_USERS_TO_CREATE=disaster-resilience housing-affordability local-elections transportation-systems urban-development

### About `DB_USERS_TO_CREATE`

I’ve provided these to facilitate database ownership wrangling and
backup-restore testing. As given in `sample.env`, these are the accounts
Hack Oregon’s PostgreSQL server will have. Some notes:

-   In the `postgis` image, they are also Linux users. For example, you
    can
    `docker-exec -it -u disaster-resilience containers_postgis_1 /bin/bash`
    and you’ll be at a command prompt as `disaster-resilience`.

    In the `postgis` image, they are database superusers. For example,
    you can do `createuser` to create a database user and `createdb` to
    create a database. The “home database” for each of these users - a
    database with the same name as the Linux and database user - is
    created the first time the container comes up.
-   In the `amazon` image, they are *not* Linux users, nor are they
    database superusers. They are created with the same permissions they
    have on the Hack Oregon PostgreSQL server:
    `--no-createdb --no-createrole --no-superuser --no-replication`.
-   Because these names have hyphens in them, PostgreSQL in both images
    requires they be enclosed in double-quotes in SQL statements.
    -   WRONG: `ALTER DATABASE disaster OWNER TO disaster-resilience;`
    -   RIGHT: `ALTER DATABASE disaster OWNER TO "disaster-resilience";`

See the demo in `exanples/reowning_a_database` for an example of how
these users can be exploited in database wrangling.

Starting the services
---------------------

1.  Choose your version:

    -   `postgis.yml`: PostGIS only. If you’re doing all the analysis on
        the host and just want the PostGIS service, choose this. If
        you’re an experienced Linux command-line user, this image has a
        comprehensive collection of extract-transform-load (ETL) and GIS
        tools.
    -   `jupyter.yml`: PostGIS and Jupyter Choose this if you want to
        run a Jupyter notebook server inside the Docker network.
    -   `rstats.yml`: PostGIS and RStudio Server. Choose this if you
        want an RStudio Server inside the Docker network.
    -   `amazon.yml`: PostGIS and an Amazon Linux 2 server running
        PostgreSQL. This is a specialized configuration for testing
        database backups for AWS server readiness. Most users won’t need
        to use this.

2.  Type `docker-compose -f <version> up -d --build`. Docker will
    build/rebuild the images and start the services.

    Note that if you want to bring up ***all*** the services in one
    shot, just type `docker-compose up -d --build`. This takes quite a
    bit of time - from 45 minutes to an hour the first time, depending
    on download bandwidth and disk I/O speed.

The PostGIS service
-------------------

The `postgis` service is based on the official PostgreSQL image from the
Docker Store: <https://store.docker.com/images/postgres>. It is running

-   PostgreSQL 9.6,
-   PostGIS 2.4,
-   pgRouting 2.5, and
-   all of the foreign data wrappers that are available in a Debian
    `jessie` PostgreSQL server.

All the images except `amazon` acquire PostgreSQL and its accomplices
from the official PostgreSQL Global Development Group (PGDG) Debian
repositories: <https://www.postgresql.org/download/linux/debian/>.

### Using the command line

I’ve tried to provide a comprehensive command line experience. `Git`,
`curl`, `wget`, `lynx`, `nano` and `vim` are there, as is most of the
command-line GIS stack (`gdal`, `proj`, `spatialite`, `rasterlite`,
`geotiff`, `osm2pgsql` and `osm2pgrouting`), and of course `psql`.

I’ve also included `python3-csvkit` for Excel, CSV and other text files,
`unixodbc` for ODBC connections and `mdbtools` for Microsoft Access
files. If you want to extend this image further, it is based on Debian
`jessie`.

You can log in as the Linux superuser `root` with
`docker exec -it -u root containers_postgis_1 /bin/bash`.

I’ve added a database superuser called `dbsuper`. This should be your
preferred login, rather than using the system database superuser
`postgres`. Log in with
`docker exec -it -u dbsuper -w /home/dbsuper containers_postgis_1 /bin/bash`.

### Linux host convenience scripts

For Linux hosts, including Windows 10 Pro Windows Subsystem for Linux
Ubuntu
(<https://github.com/hackoregon/data-science-pet-containers/blob/master/win10pro-wsl-ubuntu-tools/README.md>),
I’ve created some convenience scripts:

-   `login2postgis.bash`: Type `./login2postgis.bash` and you’ll be
    logged into the `containers_postgis_1` container as `dbsuper`. You
    can also log in as one of the users in `DB_USERS_TO_CREATE`, for
    example, `./login2postgis.bash local-elections`.
-   `login2amazon.bash`: Log in to `containers_amazon_1` as `dbsuper`.
-   `pull-postgis-backups.bash`: This script does
    `docker cp containers_postgis_1:/home/dbsuper/Backups`. That is, it
    copies all the files from `/home/dbsuper/Backups` into `Backups` in
    your current directory, creating `Backups` if it doesn’t exist.

    I use this for transferring backup files for testing; I’ll create a
    database in the PostGIS container, create a backup in
    `/home/dbsuper/Backups` and copy it out to the host with this
    script.
-   `push-amazon-backups.bash`: This is the next step - it copies
    `Backups` to `/home/dbsuper/Backups` in `containers_amazon_1` for
    restore testing.

### Virtualenvwrapper

You can use the Python `virtualenvwrapper` utility. See
<https://virtualenvwrapper.readthedocs.io/en/latest/#> for the
documentation.

To activate, enter
`source /usr/share/virtualenvwrapper/virtualenvwrapper.sh`.

### Setting up `git`

1.  Log in with `docker exec` as `dbsuper` as described above.
2.  `cd /home/dbsuper`.
3.  Edit `configure-git.bash`. You’ll need to supply your email address
    and name.
4.  Enter `./configure-git.bash`.

To clone a repository, use its `https` URL. For a private repository,
you’ll need to authenticate when you clone. For a public one, you’ll
only have to authenticate if you want to push.

In either case, once you’ve authenticated, `git` will cache your
credentials for an hour. As you probably noticed, this timeout is
adjustable in `configure-git.bash`.

Cloning this repository:

1.  Log in with `docker exec` as `dbsuper` as described above.
2.  `cd /home/dbsuper`.
3.  Enter `./clone-me.bash`.

You will find the repository in
`$HOME/Projects/data-science-pet-containers`

### Connecting to the service

-   From the host, connect to `localhost`, port `HOST_POSTGRES_PORT`.
-   Inside the Docker network, connect to `postgis`, port 5432.
-   In both cases, the username and maintenance database are `postgres`
    and the password is `POSTGRES_PASSWORD`.
-   From the command line, when you are logged in as the database
    superuser `postgres`, you do not need a password to connect.

### Connecting with pgAdmin on the host

If you’ve installed the EnterpriseDB PostgreSQL distribution, you
probably already have pgAdmin, although it may not be the latest
version. If you want to install pgAdmin without PostgreSQL:

-   macOS installer: <https://www.pgadmin.org/download/pgadmin-4-macos/>
-   Windows installer:
    <https://www.pgadmin.org/download/pgadmin-4-windows/>

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

1.  Make sure all objects in the source databases have owners that will
    exist in the destination database. If the owner of an object doesn’t
    exist in the destination, the restore will fail.
2.  For each database you want restored, create a backup file. For
    documentation / repeatability, do this with `pg_dump` on the command
    line or in a script:

        pg_dump -Fp -v -C -c --if-exists -d <database> \
        | gzip -c > <database>.sql.gz

    where `<database>` is the name of the database.

    At restore time, a new database will be created (`-C -c`). This is
    done by DROPping existing objects; the `--if-exists` keeps the DROPs
    from failing if the objects don’t exist.
3.  Copy the database backup files to
    `data-science-pet-containers/containers/Backups`. Note that
    `.gitignore` is set for the common backup file extensions -
    `*.sql.gz`, `*.sql` and `*.backup` - so these backup files won’t be
    version-controlled.
4.  Type `docker-compose -f postgis.yml build`.

Docker will copy the backup files into `/home/dbsuper/Backups` on the
`postgis` image, and place a script `restore-all.sh` in
`/docker-entrypoint-initdb.d/`. The first time the image runs,
`restore-all.sh` will

-   Create all the database users you defined in `DB_USERS_TO_CREATE`,
    and then
-   restore all the `.backup`, `.sql.gz` and `.sql` files it finds in
    `/home/dbsuper/Backups`.

### The `Raw` directory

If you want to load raw data onto the `postgis` image, copy the files to
the `data-science-pet-containers/containers/Raw` directory. The next
time the image is built they will be copied to `/home/dbsuper/Raw`. Like
the backups, these files are not version-controlled.

Jupyter
-------

This service is based on the Anaconda, Inc. (formerly Continuum)
`miniconda3` image: <https://hub.docker.com/r/continuumio/miniconda3/>.
I’ve added a non-root user `jupyter` to avoid the security issues
associated with running Jupyter notebooks as “root”.

The `jupyter` user has a Conda environment, also called `jupyter`. In
addition to `jupyter`, the environment has

-   geopandas,
-   jupyter,
-   matplotlib,
-   pandas,
-   psycopg2,
-   requests,
-   seaborn,
-   statsmodels,
-   cookiecutter, and
-   osmnx.

By default the Jupyter notebook server starts when Docker brings up the
service. Type `docker logs conatiners_jupyter_1`. You’ll see something
like this:

    $ docker logs conatiners_jupyter_1 
    [I 08:00:22.931 NotebookApp] Writing notebook server cookie secret to /home/jupyter/.local/share/jupyter/runtime/notebook_cookie_secret
    [I 08:00:23.238 NotebookApp] Serving notebooks from local directory: /home/jupyter
    [I 08:00:23.238 NotebookApp] 0 active kernels
    [I 08:00:23.238 NotebookApp] The Jupyter Notebook is running at:
    [I 08:00:23.238 NotebookApp] http://0.0.0.0:8888/?token=d90b23c9368933095c9fd8e25f29d2ba48f7ce67247e216d
    [I 08:00:23.238 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
    [C 08:00:23.238 NotebookApp] 
        
        Copy/paste this URL into your browser when you connect for the first time,
        to login with a token:
            http://0.0.0.0:8888/?token=d90b23c9368933095c9fd8e25f29d2ba48f7ce67247e216d

Browse to `localhost:8888` and copy/paste the token when the server asks
for it.

### Setting up `git`

1.  Edit `configure-git.bash` with the Jupyter notebook file editor.
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

Cloning this repository:

1.  Open a new terminal using the `New -> Terminal` dropdown at the
    upper right of the `Home` tab.
2.  Enter `./clone-me.bash`.

You will find the repository in
`$HOME/Projects/data-science-pet-containers`

### Installing packages

To install packages:

1.  Open a new terminal using the `New -> Terminal` dropdown at the
    upper right of the `Home` tab.
2.  Enter `bash`. The terminal comes up initially in the `sh` shell,
    which is missing many command-line conveniences.
3.  Enter `source activate jupyter`.
4.  Use `conda search` to find packages in the Conda ecosystem, then
    install them with `conda install`. You can also install packages
    with `pip` if they’re not in the Conda repositories.

### Connecting to the `postgis` service

To connect to the `postgis` service, use the user name and maintenance
database name `postgres`. The host is `postgis`, the port is 5432 and
the password is the value of `POSTGRES_PASSWORD`.

### Creating a Cookiecutter data science project

Reference: <https://drivendata.github.io/cookiecutter-data-science/>

1.  Open a new terminal using the `New -> Terminal` dropdown at the
    upper right of the `Home` tab.
2.  Enter `./make-cookiecutter-project`.

The script will install `cookiecutter` in the `jupyter` environment if
necessary. Then it will launch the Cookiecutter data science interactive
setup to create a new project in `/home/jupyter/Projects`.

Follow the instructions to set up the project.

Rstats
------

This service is based on the `rocker/rstudio` image from Docker Hub:
<https://hub.docker.com/r/rocker/rstudio/>. I’ve added header files so
that the R packages `RPostgres`, `odbc`, `sf` and `devtools` will
install from source, but there are no R packages on the image besides
those that ship with `rocker/rstudio`.

Browse to `localhost:8787`. The user name and password are both
`rstudio`. ***Note that if you’re using Firefox, you may have to adjust
a setting to use the terminal feature.***

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

Cloning this repository:

1.  Open a new terminal and enter `./clone-me.bash`.

You will find the repository in
`$HOME/Projects/data-science-pet-containers`

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

### Connecting to the `postgis` service

To connect to the `postgis` service, use the user name and maintenance
database name `postgres`. The host is `postgis`, the port is 5432 and
the password is the value of `POSTGRES_PASSWORD`.

Amazon
------

This image is based on the Amazon Linux 2 “2-with-sources” Docker image
at <https://hub.docker.com/_/amazonlinux/>. The main reason it’s in this
collection is to provide a means of restore-testing backup files before
handing them off to the DevOps engineers for deployment on AWS.

1.  Read the section on automatic restores and backup file preparation
    above ([Using automatic database
    restores](#using-automatic-database-restores)).
2.  Copy the backup files into
    `data-science-pet-containers/containers/Backups`.
3.  `docker-compose -f amazon.yml up -d --build`. The backup files will
    be copied to `/home/dbsuper/Backups` on both the `postgis` and
    `amazon` images.
4.  When the services are up, type
    `docker logs -f containers_postgis_1`. The backup files should be
    automatically restored. If there are errors, you’ll need to fix your
    backup files. When the restores are done, type `CTL-C` to stop
    following the log.
5.  Log in to the `amazon` container -
    `docker exec -it -u dbsuper -w /home/dbsuper containers_amazon_1 /bin/bash`.
6.  `cd Backups; ls`. You’ll see the backup files. For example:

        $ cd Backups; ls
        odot_crash_data.sql.gz  passenger_census.sql.gz  restore-all.sh

    Those are the same backup files you just successfully restored in
    the `postgis` image.
7.  Type `./restore-all.sh`. This is the same script that did the
    automatic restores on `postgis` and it should have the same result.
    If there are no errors in the automatic restore on `postgis` and the
    restore you just did in `amazon` the backup files are good. To bring
    it up, type `docker-compose -f amazon,yml up -d --build`.

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
