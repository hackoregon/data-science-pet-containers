# data-science-pet-containers
Pet containers for data scientists

## What is this?
This repository contains the code for building Docker images and running services with them. It is organzied as follows:

* `images` contains Dockerfiles and other files needed to build Docker images. Each image has its own folder.
* `networks` contains `docker-compose.yml` files to bring up Docker networks of services.

## What you will need
Docker hosting - you will need Docker Community Edition (latest stable) or the equivalent. You will need to have both `docker` and `docker-compose` in your PATH and you will need to be a member of the `docker` group.

I regularly test on Arch Linux, currently

    * Docker version 18.01.0-ce, build 03596f51b1
    * docker-compose version 1.18.0, build unknown

I also test on Docker for Windows on Windows 10 Pro in the `bash` terminal that comes with Git for Windows.
