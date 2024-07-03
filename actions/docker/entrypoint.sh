#!/bin/bash
set -e

mkdir -p ~/.ssh
echo "$INPUT_SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
chmod 0400 ~/.ssh/id_rsa

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
echo "StrictHostKeyChecking no" >> $(find /etc -iname ssh_config)

docker context create prod --docker host="ssh://$INPUT_SSH_USER@$INPUT_SSH_HOST"
docker context use prod

docker stop $(docker ps --filter name=$INPUT_CONTAINER_NAME -q)
docker run $INPUT_DOCKER_VOLUMES $INPUT_DOCKER_PORTS $INPUT_DOCKER_ENV -d --rm --name $INPUT_CONTAINER_NAME $INPUT_IMAGE
