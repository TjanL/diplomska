FROM docker:cli

RUN apk add --no-cache openssh-client
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
