#!/bin/bash
sourceDb="http://localhost:5984/"$2
targetDb=$1/$2
/usr/local/bin/backuprestore "$sourceDb" "$targetDb"