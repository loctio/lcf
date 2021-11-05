#!/bin/bash

if [ ! -f docker-compose.yml ];
then
  curl -fsSL -o docker-compose.yml https://raw.githubusercontent.com/loctio/lcf/master/scripts/linux/docker-compose.yml
  if [ $? -ne 0 ];
  then
    echo "Error occured during docker-compose.yml download. Please contact LCF administrator at lcf@loctio.com"
    exit $?
  fi
fi

echo -n "Enter network interface name that will connect to LCF: "
read ETHIF
ETHIF_EXISTS=$(ip link show $ETHIF)
if [ $? -ne 0 ];
then
  echo "Error occured during $ETHIF configuration. Please contact LCF administrator at lcf@loctio.com"
  exit $?
fi
MAC_ADDRESS=$(echo $ETHIF_EXISTS | awk -F'/ether' '{print $2}' | tail -1 | cut -d' ' -f2)

echo -n "Enter the API TOKEN you received in the LCF confirmation email: "
read TOKEN

echo "MAC_ADDRESS=${MAC_ADDRESS}" > .env-cloud
echo "CLOUD_API_HOST=staging-api.loctio.com" >> .env-cloud
echo "TOKEN=${TOKEN}" >> .env-cloud
echo "ECR=docker.io" >> .env-cloud
source .env-cloud

echo "Pulling docker image from $ECR"
docker pull $ECR/loctio/ue_x86_64:latest

docker-compose --env-file .env-cloud -f docker-compose.yml down
docker-compose --env-file .env-cloud -f docker-compose.yml --compatibility up -d loctio_ue_x86_64
docker logs -f loctio_ue
