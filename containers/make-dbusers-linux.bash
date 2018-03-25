#! /bin/bash

# create the users we'll be restoring to!
for user in $DB_USERS_TO_CREATE
do
  echo "Creating Linux user $user"
  useradd --shell /bin/bash --user-group --create-home $user
done
