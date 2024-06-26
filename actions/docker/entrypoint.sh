#!/bin/bash
set -e

mkdir -p ~/.ssh
touch ~/.ssh/known_hosts
echo "$INPUT_SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
chmod 0400 ~/.ssh/id_rsa
ssh-keyscan -t rsa $INPUT_SSH_HOST >> ~/.ssh/known_hosts

docker context create prod --docker host="ssh://$INPUT_SSH_USER@$INPUT_SSH_HOST"
docker context use prod

docker stop $(docker ps --filter name=$INPUT_CONTAINER_NAME -q)
docker run $INPUT_DOCKER_VOLUMES $INPUT_DOCKER_PORTS $INPUT_DOCKER_ENV -d --rm --name $INPUT_CONTAINER_NAME $INPUT_IMAGE
