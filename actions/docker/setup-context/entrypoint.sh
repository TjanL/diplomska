#!/bin/bash
set -e

mkdir -p ~/.ssh
echo "$INPUT_SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
chmod 0400 ~/.ssh/id_rsa

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
echo "StrictHostKeyChecking no" >> $(find /etc -iname ssh_config)

docker context create $INPUT_CONTEXT --docker host="ssh://$INPUT_SSH_USER@$INPUT_SSH_HOST"
