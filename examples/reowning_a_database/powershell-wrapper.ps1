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
$user="$env:DB_SUPERUSER"
$workdir="/home/$env:DB_SUPERUSER"
$dbname="$env:DB_NAME"
$command="/home/$env:DB_SUPERUSER/reown-demo.bash"
docker exec -it -u $user -w $workdir -e DB_NAME=$dbname -e USER=$user containers_postgis_1 $command

Write-Host "Retriving the compressed SQL backup"
docker cp "containers_postgis_1:home/$env:DB_SUPERUSER/$env:DB_NAME.sql.gz" .
ls -ltr
