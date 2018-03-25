#! /bin/bash

createuser --superuser dbsuper || true
createdb --owner=dbsuper dbsuper || true

# create the users we'll be restoring to!
for user in $DB_USERS_TO_CREATE
do
  echo "Creating database superuser $user with home database $user"
  createuser --superuser $user || true
  createdb --owner=$user $user || true
done
