#!/bin/sh -l

# Add SSH key
mkdir -p ~/.ssh
echo "$INPUT_SSH_KEY" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
echo "StrictHostKeyChecking no" >> $(find /etc -iname ssh_config)

# Create Docker context and use it
docker context create remote-docker --docker "host=ssh://$INPUT_REMOTE_DOCKER_HOST"
docker context use remote-docker

# Optionally log in to Docker registry
if [ -n "$INPUT_DOCKER_REGISTRY" ] && [ -n "$INPUT_DOCKER_USERNAME" ] && [ -n "$INPUT_DOCKER_PASSWORD" ]; then
  echo "$INPUT_DOCKER_PASSWORD" | docker login "$INPUT_DOCKER_REGISTRY" -u "$INPUT_DOCKER_USERNAME" --password-stdin
fi

# Prepare environment variable options
env_vars=""
if [ -n "$INPUT_ENV_VARS" ]; then
  for var in $(echo "$INPUT_ENV_VARS" | tr ',' '\n'); do
    env_vars="$env_vars -e $var"
  done
fi

# Prepare port options
port_option=""
if [ -n "$INPUT_PORTS" ]; then
  for portPair in $(echo "$INPUT_PORTS" | tr ',' '\n'); do
    port_option="$port_option -p $portPair"
  done
fi

# Prepare volume options
volume_options=""
if [ -n "$INPUT_VOLUMES" ]; then
  for volume in $(echo "$INPUT_VOLUMES" | tr ',' '\n'); do
    volume_options="$volume_options -v $volume"
  done
fi

# Prepare network options and create network if it doesn't exist
network_option=""
if [ -n "$INPUT_NETWORK" ]; then
  if ! docker network inspect "$INPUT_NETWORK" >/dev/null 2>&1; then
    docker network create "$INPUT_NETWORK"
  fi
  network_option="--network $INPUT_NETWORK"
fi

# Deploy the Docker image
docker pull "$INPUT_DOCKER_IMAGE"
docker stop "$INPUT_CONTAINER_NAME" || true
docker rm "$INPUT_CONTAINER_NAME" || true
docker run -d --name "$INPUT_CONTAINER_NAME" $env_vars $port_option $volume_options $network_option "$INPUT_DOCKER_IMAGE"
