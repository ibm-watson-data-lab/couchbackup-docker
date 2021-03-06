#!/bin/bash

sourceDb=$1
targetDb=$2

RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

maxConnectAttempts=15
numConnectAttempts=0
maxInvalidReplicationStateAttempts=3
numInvalidReplicationStateAttempts=0

# connect to CouchDB
echo "$(date) - Trying to connect to CouchDB..."
statusCode="$(curl -f -s -o /dev/null -w "%{http_code}" --head http://couchdb:5984/)"
while [ $statusCode -ne "200" ]; do
    numConnectAttempts=$((numConnectAttempts+1))
    if [ "$numConnectAttempts" -ge "$maxConnectAttempts" ]; then
        echo -e "$(date) - ${RED}Unable to connect to CouchDB.${NOCOLOR}"
        exit 1
    fi
    echo "$(date) - Status Code=$statusCode"
    echo "$(date) - Retrying to connect to CouchDB in 3 seconds..."
    sleep 3
    statusCode="$(curl -f -s -o /dev/null -w "%{http_code}" --head http://couchdb:5984/)"
done
echo "$(date) - Connected to CouchDB."

# create replication
echo "$(date) - Creating replication..."
json=$(echo "{\"source\":\""$sourceDb"\",\"target\":\""$targetDb"\",\"create_target\":true}")
cmd=$(echo "curl -s -d '"$json"' -H 'Content-Type: application/json' -X PUT http://couchdb:5984/_replicator/couchbackup")
ok=$(eval $cmd | jq '.ok')
if [ $ok != "true" ]; then
    echo -e "$(date) - ${RED}Replication failed.${NOCOLOR}"
    exit 1
fi
echo "$(date) - Replication created."

# wait for replication to complete
sleep 5
echo "$(date) - Checking replication state..."
replicationState="$(curl -s http://couchdb:5984/_replicator/couchbackup | jq '._replication_state')"
while [ $replicationState != "\"completed\"" ]; do
    if [ $replicationState == "\"error\"" ]; then
        echo -e "$(date) - ${RED}Replication failed with error.${NOCOLOR}"
        exit 1
    elif [ $replicationState != "\"triggered\"" ]; then
        numInvalidReplicationStateAttempts=$((numInvalidReplicationStateAttempts+1))
        if [ "$numInvalidReplicationStateAttempts" -ge "$maxInvalidReplicationStateAttempts" ]; then
            echo -e "$(date) - ${RED}Replication failed with invalid state.${NOCOLOR}"
            exit 1
        fi
    fi
    echo "$(date) - Replication State=$replicationState"
    echo "$(date) - Checking replication state in 15 seconds..."
    sleep 15
    echo "$(date) - Checking replication state..."
    replicationState="$(curl -s http://couchdb:5984/_replicator/couchbackup | jq '._replication_state')"
done
echo -e "$(date) - ${GREEN}Replication complete.${NOCOLOR}"