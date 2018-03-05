FROM alpine:latest

RUN apk add --no-cache bash curl jq

COPY backuprestore.sh /usr/local/bin/backuprestore
COPY backup.sh /usr/local/bin/backup
COPY restore.sh /usr/local/bin/restore

CMD ["/bin/bash"]