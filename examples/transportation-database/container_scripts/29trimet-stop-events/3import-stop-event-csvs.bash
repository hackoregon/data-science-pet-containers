#! /bin/bash

# define parameters
export DBOWNER=transportation-systems
export PGDATABASE=transportation-systems-main

echo "Creating the 'trimet_stop_events' (congestion data) table"
/usr/bin/time psql -U ${DBOWNER} -d ${PGDATABASE} -f trimet-stop-events.psql
