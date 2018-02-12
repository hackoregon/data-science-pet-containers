Data Science Pet Containers
================
M. Edward (Ed) Borasky
2018-02-11

Setup
-----

1.  Make sure you have reliable power and internet bandwidth. The build phase does a fair amount of downloading. Install Docker hosting if you haven't already - Docker Community Edition or its equivalent. You will need the `docker` and `docker-compose` executables in your `PATH`.
2.  Clone this repository and `cd data-science-pet-containers/containers`.
3.  Define the environment variables in a file called `.env`. Note that this file is in `.gitignore` and will ***not*** be version-controlled. The variables you need to define are

    -   HOST\_POSTGRES\_PORT: The `postgis` service listens on port 5432. Docker will map that port into this port on `localhost`.
    -   POSTGRES\_PASSWORD: Docker will set the password for the `postgres` user in the `postgis` service to this value.
    -   HOST\_PGADMIN\_PORT: The `pgadmin4` service listens on port 80. Docker will map that port into this port on `localhost`.
    -   PGADMIN\_DEFAULT\_EMAIL: You log in to the `pgadmin4` web service with an email address and password. Docker will set the email address to this value.
    -   PGADMIN\_DEFAULT\_PASSWORD: The password
    -   HOST\_RSTUDIO\_PORT: The `rstudio` service listens on port 8787. Docker will map that port into this port on `localhost`.

    Here's a sample `.env` you can copy / paste and edit to your liking:

        # postgis container
        HOST_POSTGRES_PORT=5439
        POSTGRES_PASSWORD=some.string.you.can.remember.that.nobody.else.can.guess

        # pgadmin4 container
        HOST_PGADMIN_PORT=8080
        PGADMIN_DEFAULT_EMAIL=znmeb@znmeb.net
        PGADMIN_DEFAULT_PASSWORD=some.string.you.can.remember.that.nobody.else.can.guess

        # rstudio server container
        HOST_RSTUDIO_PORT=8786

4.  Type `docker-compose build`. Wait. On my workstation (4 GHz 8 core, 60 mbits/second download) it takes about 15 minutes for Docker to build the images. When it's done, type `docker images` to list them.

        $ docker images
        REPOSITORY               TAG                 IMAGE ID            CREATED             SIZE
        jupyter                  latest              7617c09618c4        27 seconds ago      2.69GB
        rstudio                  latest              d04ea9cee239        5 minutes ago       1.4GB
        pgadmin4                 latest              7ce769581b94        10 minutes ago      558MB
        postgis                  latest              3f464c995eec        11 minutes ago      587MB

Running
-------

Type `docker-compose up -d`. Docker will create a network called `containers_default`. There will be four containers, one for each service.

    $ docker-compose up -d
    Creating network "containers_default" with the default driver
    Creating containers_postgis_1  ... done
    Creating containers_pgadmin4_1 ... done
    Creating containers_rstudio_1  ... done
    Creating containers_jupyter_1  ... done

About the services
------------------

### PostGIS

The `postgis` service is based on the official PostgreSQL image from the Docker Store: <https://store.docker.com/images/postgres>. It is running PostgreSQL 10, PostGIS 2.4, pgRouting and all of the foreign data wrappers that are available in a Debian PostgreSQL server.

Inside the network it can be accessed as host `postgis` on port `5432`. Outside the network, it's on `localhost` at port `HOST_POSTGRES_PORT`. Note that all of these images except `pgadmin4` acquire PostgreSQL and its accomplices from the official PostgreSQL Debian repositories: <https://www.postgresql.org/download/linux/debian/>.

### pgAdmin4

pgAdmin4 is available in two forms - as a desktop application and as a web application. This service is the web application. *Note that it can only access PostgreSQL services inside the network*.

The pgAdmin4 service is based on an experimental image: <https://hub.docker.com/r/dpage/pgadmin4/>. The Dockerfile is here: <https://github.com/postgres/pgadmin4/blob/master/pkg/docker/Dockerfile>. Unlike the other images, it's based on CentOS rather than Debian. If this service proves useful I can build a new one based on Debian for consistency.

To start use it, browse to port `HOST_PGADMIN_PORT` on `localhost`. It will grind for a while, then give you a login form. The email address is the one you set in `.env` for `PGADMIN_DEFAULT_EMAIL` and the password is the one you set for `PGADMIN_DEFAULT_PASSWORD`.

After you log in, it will grind for a while again; this only happens the first time. Then you'll get the `pgAdmin` tree on the left. Right-click on `Servers` and create a server.

Give it any name you want. Then on the `Connection` tab, set the host to `postgis`, the port to `5432`, the maintenance database to `postgres`, the user name to `postgres` and the password to the value you set for `POSTGRES_PASSWORD`. Check the `Save password` box and press the `Save` button. pgAdmin will add the tree for the `postgis` service.

### RStudio

This service is based on the `rocker/rstudio` image from Docker Hub: <https://hub.docker.com/r/rocker/rstudio/>. I've added some database connectivity tools and the `vim-nox` editor.

Browse to `localhost` on `HOST_RSTUDIO_PORT`. The user name and password are both `rstudio`. Note that if you're using Firefox, you'll have to adjust a setting to use the terminal feature. Go to `Tools -> Global Options -> Terminal`. For Firefox, you need to uncheck the `Connect with WebSockets` option. Other browsers I've tried, Microsoft Edge and Chromium, don't need this.

### Jupyter

This service is based on the Anaconda, Inc. (formerly Continuum) `miniconda3` image: <https://hub.docker.com/r/continuumio/miniconda3/>. I've added a non-root user `jupyter` and created a Conda environment also named `jupyter` in its home directory. I've only put `jupyter`, `cookiecutter` and `psycopg2` in the Conda environment for now. The `vim-nox` editor is also available.

By default the Jupyter notebook server starts when Docker brings up the service. Type `docker logs containers_jupyter_1`. You'll see something like this:

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

That link is where you want to point your browser. Or you can just browse to `localhost:8888` and paste the token when it asks for it.

The Jupyter "New Terminal" works, but the terminal is coming up in `sh` instead of `bash` for some reason. So if you use the terminal, type `bash; source activate jupyter` to get something usable.

Integration with host data volumes
----------------------------------

TBD - my plan is to define a [Cookiecutter Data Science](http://drivendata.github.io/cookiecutter-data-science/) project in another image / container to use as a data volume.

About the name
--------------

This all started with an infamous "cattle, not pets" blog post. For some history, see <http://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/>. In the Red Hat / Kubernetes / OpenShift universe, it's common for people to have a workstation that's essentially a Docker / Kubernetes host with all the actual work being done in containers. See <https://rhelblog.redhat.com/2016/06/08/in-defense-of-the-pet-container-part-1-prelude-the-only-constant-is-complexity/> and <https://www.projectatomic.io/blog/2018/02/fedora-atomic-workstation/>.

So - pet containers for data scientists.
