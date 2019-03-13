#! /bin/bash

if [ "$#" -ne 1 ]; then
    echo "You must specify a directory containing the input data as the only argument to this script!"
    exit 129
fi
export RAW=${1}
echo "Inputs will come from ${RAW}"
echo "Copying the scripts to the container"
docker cp container_scripts containers_postgis_1:/home/dbsuper

echo "Copying input data to the container"
docker exec -u dbsuper containers_postgis_1 rm -fr /home/dbsuper/Raw
docker cp ${RAW} containers_postgis_1:/home/dbsuper/Raw

echo "Running the scripts in the container"
echo ""
echo ""
docker exec -it -u dbsuper -w /home/dbsuper/container_scripts containers_postgis_1 \
  ./create-all-tables.bash

echo "Retriving the backups"
docker cp containers_postgis_1:home/dbsuper/Raw/transportation-systems-main.sql.gz ${RAW}/
docker cp containers_postgis_1:home/dbsuper/Raw/transportation-systems-main.sql.gz.sha512sum ${RAW}/
pushd ${RAW}/
echo "Validating backup sha512sum"
sha512sum -c transportation-systems-main.sql.gz.sha512sum
echo "Testing backup decompression"
gzip -dc transportation-systems-main.sql.gz | wc -c
popd
