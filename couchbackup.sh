rm -rf ./data
docker-compose run couch backup $1 $2
docker-compose down
cp ./data/$2.couch ./