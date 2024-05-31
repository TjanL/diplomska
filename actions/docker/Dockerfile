FROM alpine:3.19

RUN apt add --no-cache dropbear-ssh docker-cli
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
