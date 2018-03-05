# couchbackup-docker

CouchBackup-Docker is a command-line utility that allows a Cloudant or CouchDB database to be backed up to a .couch file. It comes with a companion command-line utility that can restore the backed up data.

### Usage

* Note: This utility requires [Docker Compose](https://docs.docker.com/compose/).

#### Clone this repo:

```
git clone https://github.com/ibm-watson-data-lab/couchbackup-docker
cd couchbackup-docker
```

#### To back up, run:

```
./couchbackup.sh https://user:pass@myhost-to-be-backed-up.cloudant.com mydb
```

This will create a file named _mydb_.couch in the working directory.

#### To restore, run:

```
./couchrestore.sh https://user:pass@myhost-to-be-restored.cloudant.com mydb
```

This requires a _mydb_.couch file in the working directory.