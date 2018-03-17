#! /bin/bash

# assumes
# 1. Linux,
# 2. PostgreSQL with trust authentication for your user ID, You do *not* need PostGIS!
# 3. Your user ID has superuser privileges.

echo "Restoring 'passenger_census'"
gzip -dc /home/dbsuper/Backups/passenger_census.sql.gz | psql
