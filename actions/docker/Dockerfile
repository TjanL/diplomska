FROM alpine:3.19

RUN apk add --no-cache openssh docker-cli
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
