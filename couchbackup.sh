#!/bin/bash
printSyntax() {
   echo "Syntax:"
   echo "   ./couchbackup.sh <full url> or ./couchbackup.sh <partial url> <database>"
   echo "e.g." 
   echo "   ./couchbackup.sh https://user:pass@myhost.cloudant.com/mydb"
}

url=$1
db=$2
if [ "$#" -eq 0 ]; then
   echo "Error: Missing URL"
   printSyntax
   exit 1
elif [ "$#" -ne 1 ] && [ "$#" -ne 2 ]; then
   echo "Error: Too Many Arguments"
   printSyntax
   exit 1
elif [ "$#" -eq 1 ]; then
   # If one arg pull out the db name
   parts=(${1//\// })
   numParts=${#parts[*]}
   if [ $numParts -ne 3 ]; then
      echo "Error: Invalid URL"
      printSyntax
      exit 1
   else
      url=$(echo ${parts[0]}"//"${parts[1]})
      db=${parts[2]}
   fi
fi

docker-compose build
docker-compose run couchbackup backup $url $db
docker-compose down
mv ./data/$db.couch ./
rm -rf ./data