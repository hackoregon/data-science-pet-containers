Re-owning a ‘disaster-resilience’ Database
================

## Setup

1.  Clone <https://github.com/hackoregon/data-science-pet-containers>.
2.  `cd data-science-pet-containers/containers`.
3.  Copy the `disaster.backup` file to
    `data-science-pet-containers/containers/Raw`.
4.  `docker-compose -f postgis.yml up -d --build`. This will copy the
    raw data to the `postgis` image and bring it up in a container.

## Running

1.  `cd
    Projects/data-science-pet-containers/examples/reowning_a_database`.
2.  `./run-from-linux.bash`. The script will copy the raw data and
    conversion scripts to the container, run the scripts, and copy the
    results to `data-science-pet-containers/containers/Raw`.
