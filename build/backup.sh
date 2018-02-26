#!/bin/bash

# connect to CouchDB
echo "$(date) - Trying to connect to CouchDB..."
statusCode="$(curl -f -s -o /dev/null -w "%{http_code}" --head http://couchdb:5984/)"
while [ $statusCode -ne "200" ]; do
    echo "$(date) - Status Code=$statusCode; retrying to connect to CouchDB..."
    sleep 3
    statusCode="$(curl -f -s -o /dev/null -w "%{http_code}" --head http://couchdb:5984/)"
done
echo "$(date) - Connected to CouchDB."

# create replication
sourceDb=$1/$2
targetDb="http://localhost:5984/"$2
echo "$(date) - Creating replication..."
json=$(echo "{\"source\":\""$sourceDb"\",\"target\":\""$targetDb"\",\"create_target\":true}")
cmd=$(echo "curl -s -d '"$json"' -H 'Content-Type: application/json' -X PUT http://couchdb:5984/_replicator/couchbackup")
ok=$(eval $cmd | jq '.ok')
if [ $ok != "true" ]; then
    echo "$(date) - Replication failed."
    exit 1
fi
echo "$(date) - Replication created."

# wait for replication to complete
echo "$(date) - Checking replication state..."
replicationState="$(curl -s http://couchdb:5984/_replicator/couchbackup | jq '._replication_state')"
while [ $replicationState != "\"completed\"" ]; do
    echo "$(date) - Replication State=$replicationState; checking replication state in 15 seconds..."
    sleep 15
    echo "$(date) - Checking replication status..."
    replicationState="$(curl -s http://couchdb:5984/_replicator/couchbackup | jq '._replication_state')"
done
echo "$(date) - Replication complete. "$2".couch created."