#!/bin/bash
set -e

if [ -z "$INPUT_DNS_SERVERS" ]; then
    echo -e $INPUT_DNS_SERVERS >> /etc/resolv.conf

mkdir -p ~/.ssh
echo "$INPUT_SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

docker context create prod --docker host="ssh://$INPUT_SSH_USER@$INPUT_SSH_HOST"
docker context use prod

docker stop $(docker ps --filter name=$INPUT_CONTAINER_NAME -q)
docker run $INPUT_DOCKER_VOLUMES $INPUT_DOCKER_PORTS $INPUT_DOCKER_ENV --detached --rm --name $INPUT_CONTAINER_NAME $INPUT_IMAGE
