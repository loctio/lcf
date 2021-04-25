#!/bin/bash

ETHIF="eth0"

if [ ! -f docker-compose.yml ];
then
  curl -fsSL -o docker-compose.yml https://raw.githubusercontent.com/loctio/lcf/master/scripts/raspbian/docker-compose.yml
  echo "docker-compose.yml has been downloaded. Make the appropriate changes and rerun ./install.sh"
  exit
fi

apt list | grep usbutils
if [ $? -eq 1 ];
then
  sudo apt-get update && sudo apt-get install usbutils
fi

MAC_ADDRESS=$(ip link show $ETHIF | awk '/ether/ {print $2}')
BUS=$(lsusb | grep RTL | cut -d' ' -f2,4 | cut -d':' -f1 | cut -d' ' -f1)
BUS_VALUE="/dev/bus/usb/$BUS/$DEV"

echo "MAC_ADDRESS=${MAC_ADDRESS}" > .env-cloud
echo "RTL_SDR_BUS=${BUS_VALUE}" >> .env-cloud
echo "CLOUD_API_HOST=api.loctio.com" >> .env-cloud
echo "ECR=docker.io" >> .env-cloud
source .env-cloud

echo "Pulling docker image from $ECR"
docker pull $ECR/loctio/ue_$(uname -m):latest

docker-compose --env-file .env-cloud -f docker-compose.yml down
docker-compose --env-file .env-cloud -f docker-compose.yml --compatibility up -d loctio_ue_$(uname -m)
docker logs -f loctio_ue