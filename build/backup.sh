#!/bin/bash
sourceDb=$1/$2
targetDb="http://localhost:5984/"$2
/usr/local/bin/backuprestore "$sourceDb" "$targetDb"