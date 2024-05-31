#!/bin/sh -l

mkdir -p ~/.ssh
echo "${{ SSH_PRIVATE_KEY }}" >> ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

docker context create prod --docker host="ssh://$SSH_USER@$SSH_HOST"
docker context use prod

docker stop $(docker ps --filter name=$CONTAINER_NAME -q)
docker run $DOCKER_VOLUMES $DOCKER_PORTS $DOCKER_ENV --detached --rm --name $CONTAINER_NAME $CONTAINER_IMAGE
