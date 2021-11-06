#!/bin/bash

if [ ! -f docker-compose.yml ];
then
  curl -fsSL -o docker-compose.yml https://raw.githubusercontent.com/loctio/lcf/master/scripts/raspbian/docker-compose.yml
  if [ $? -ne 0 ];
  then
    echo "Error occured during docker-compose.yml download. Please contact LCF administrator at lcf@loctio.com"
    exit $?
  fi
fi

apt list | grep usbutils
if [ $? -eq 1 ];
then
  sudo apt-get update && sudo apt-get install usbutils
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

BUS=$(lsusb | grep RTL | cut -d' ' -f2,4 | cut -d':' -f1 | cut -d' ' -f1)
BUS_VALUE="/dev/bus/usb/$BUS/$DEV"

echo -n "Enter the username you use in the LCF Web UI: "
read USERNAME
read -sp "Enter the password you use in the LCF Web UI: " PASSWORD
echo
echo -n "Enter the API TOKEN you received in the LCF confirmation email: "
read TOKEN

echo "MAC_ADDRESS=${MAC_ADDRESS}" > .env-cloud
echo "RTL_SDR_BUS=${BUS_VALUE}" >> .env-cloud
echo "CLOUD_API_HOST=staging-api.loctio.com" >> .env-cloud
echo "USERNAME=${USERNAME}" >> .env-cloud
echo "PASSWORD=${PASSWORD}" >> .env-cloud
echo "TOKEN=${TOKEN}" >> .env-cloud
echo "ECR=docker.io" >> .env-cloud
source .env-cloud

echo "Pulling docker image from $ECR"
docker pull $ECR/loctio/ue_$(uname -m):latest

docker-compose --env-file .env-cloud -f docker-compose.yml down
docker-compose --env-file .env-cloud -f docker-compose.yml --compatibility up -d loctio_ue_$(uname -m)
docker logs -f loctio_ue
