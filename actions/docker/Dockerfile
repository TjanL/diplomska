FROM alpine:3.19

RUN apk add --no-cache bash openssh docker-cli
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
