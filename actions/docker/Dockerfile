FROM alpine:3.19

RUN apk add --no-cache bash openssh docker-cli bind-tools
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
