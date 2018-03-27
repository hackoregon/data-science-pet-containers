$env:DB_SUPERUSER="disaster-resilience"
Write-Host "Will run as '$env:DB_SUPERUSER'; change 'DB_SUPERUSER' for a different user"
$env:DB_NAME="disaster"
Write-Host "Database name is '$env:DB_NAME'"
Write-Host ""
Write-Host ""

Write-Host "Copying the demo script to the container"
docker cp reown-demo.bash "containers_postgis_1:/home/$env:DB_SUPERUSER"

Write-Host "Copying the database backup to the container"
docker cp "$env:DB_NAME.backup" "containers_postgis_1:/home/$DB_SUPERUSER"

Write-Host "Running the demo script in the container"
Write-Host ""
Write-Host ""
docker exec -it -u "$env:DB_SUPERUSER" -w "/home/$env:DB_SUPERUSER" -e DB_NAME="$env:DB_NAME" -e USER="$env:DB_SUPERUSER" containers_postgis_1 "/home/$env:DB_SUPERUSER/reown-demo.bash"

Write-Host "Retriving the compressed SQL backup"
docker cp "containers_postgis_1:home/$env:DB_SUPERUSER/$env:DB_NAME.sql.gz" .
ls -ltr
