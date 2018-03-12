#! /bin/bash -v

createuser --superuser dbsuper
createdb --owner=dbsuper dbsuper
