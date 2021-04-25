#!/bin/bash

ETHIF="ens32"

if [ ! -f docker-compose.yml ];
then
  curl -fsSL -o docker-compose.yml https://raw.githubusercontent.com/loctio/lcf/master/scripts/linux/docker-compose.yml
  echo "docker-compose.yml has been downloaded. Make the appropriate changes and rerun ./install.sh"
  exit
fi

MAC_ADDRESS=$(ip link show $ETHIF | awk '/ether/ {print $2}')
echo "MAC_ADDRESS=${MAC_ADDRESS}" > .env-cloud
echo "CLOUD_API_HOST=api.loctio.com" >> .env-cloud
echo "ECR=docker.io" >> .env-cloud
source .env-cloud

docker pull $ECR/loctio/ue_x86_64:latest

docker-compose --env-file .env-cloud -f docker-compose.yml down
docker-compose --env-file .env-cloud -f docker-compose.yml --compatibility up -d loctio_ue_x86_64
docker logs -f loctio_ue