#! /bin/bash

# create the users we'll be restoring to!
for user in $DB_USERS_TO_CREATE
do
  echo "Creating database user $user with home database $user"
  createuser --no-createdb --no-createrole --no-superuser --no-replication $user || true
  createdb --owner=$user $user || true
done
