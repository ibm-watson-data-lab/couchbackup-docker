FROM alpine:latest

RUN apk add --no-cache bash curl jq

COPY backup.sh /usr/local/bin/backup

CMD ["/usr/local/bin/backup"]