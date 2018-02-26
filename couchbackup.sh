docker-compose run couchbackup backup $1 $2
docker-compose down
mv ./data/$2.couch ./
rm -rf ./data