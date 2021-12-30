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

while true
do
  echo -n "Enter network interface name that will connect to LCF (e.g. eth0): "
  read ETHIF
  MAC_ADDRESS=$(ip link show $ETHIF | awk '/ether/ {print $2}')
  if [ "$MAC_ADDRESS" != "" ];
  then
    break
  fi
done

echo -n "Enter the username you use in the LCF Web UI: "
read USERNAME
read -sp "Enter the password you use in the LCF Web UI: " PASSWORD
echo
echo -n "Enter the API TOKEN you received in the LCF confirmation email: "
read TOKEN

echo "MAC_ADDRESS=${MAC_ADDRESS}" > .env-cloud
echo "CLOUD_API_HOST=staging-api.loctio.com" >> .env-cloud
echo "USERNAME=${USERNAME}" >> .env-cloud
echo "PASSWORD=${PASSWORD}" >> .env-cloud
echo "TOKEN=${TOKEN}" >> .env-cloud
echo "ECR=docker.io" >> .env-cloud
source .env-cloud

echo "Pulling docker image from $ECR"
docker pull $ECR/loctio/ue_x86_64:latest

docker-compose --env-file .env-cloud -f docker-compose.yml down
docker-compose --env-file .env-cloud -f docker-compose.yml --compatibility up -d loctio_ue_x86_64
docker logs -f loctio_ue
