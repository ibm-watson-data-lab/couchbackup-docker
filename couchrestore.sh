#!/bin/bash
printSyntax() {
   echo "Syntax:"
   echo "   ./couchrestore.sh <full url> or ./couchbackup.sh <partial url> <database>"
   echo "e.g." 
   echo "   ./couchrestore.sh https://user:pass@myhost.cloudant.com/mydb"
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

if [ ! -f ./$db.couch ]; then
   echo "Error: ./"$db".couch Not Found"
   printSyntax
   exit 1
fi

mkdir -p ./data
cp ./$db.couch ./data/
docker-compose build
docker-compose run couchbackup restore $url $db
docker-compose down
rm -rf ./data