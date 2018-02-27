#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

# connect to CouchDB
echo "$(date) - Trying to connect to CouchDB..."
statusCode="$(curl -f -s -o /dev/null -w "%{http_code}" --head http://couchdb:5984/)"
while [ $statusCode -ne "200" ]; do
    echo "$(date) - Status Code=$statusCode"
    echo "$(date) - Retrying to connect to CouchDB in 3 seconds..."
    sleep 3
    statusCode="$(curl -f -s -o /dev/null -w "%{http_code}" --head http://couchdb:5984/)"
done
echo "$(date) - Connected to CouchDB."

# create replication
sourceDb="http://localhost:5984/"$2
targetDb=$1/$2
echo "$(date) - Creating replication..."
json=$(echo "{\"source\":\""$sourceDb"\",\"target\":\""$targetDb"\",\"create_target\":true}")
cmd=$(echo "curl -s -d '"$json"' -H 'Content-Type: application/json' -X PUT http://couchdb:5984/_replicator/couchrestore")
ok=$(eval $cmd | jq '.ok')
if [ $ok != "true" ]; then
    echo -e "$(date) - ${RED}Replication failed.${NOCOLOR}"
    exit 1
fi
echo "$(date) - Replication created."

# wait for replication to complete
sleep 5
echo "$(date) - Checking replication state..."
replicationState="$(curl -s http://couchdb:5984/_replicator/couchrestore | jq '._replication_state')"
while [ $replicationState != "\"completed\"" ]; do
    if [ $replicationState == "\"error\"" ]; then
        echo -e "$(date) - ${RED}Replication failed.${NOCOLOR}"
        exit 1
    fi
    echo "$(date) - Replication State=$replicationState"
    echo "$(date) - Checking replication state in 15 seconds..."
    sleep 15
    echo "$(date) - Checking replication state..."
    replicationState="$(curl -s http://couchdb:5984/_replicator/couchrestore | jq '._replication_state')"
done
echo -e "$(date) - ${GREEN}Replication complete.${NOCOLOR}"