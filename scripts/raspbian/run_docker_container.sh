#!/bin/bash

apt list | grep usbutils
if [ $? -eq 1 ];
then
  sudo apt-get update && sudo apt-get install usbutils
fi

MAC_ADDRESS=$(ip link show eth0 | awk '/ether/ {print $2}')
BUS=$(lsusb | grep RTL | cut -d' ' -f2,4 | cut -d':' -f1 | cut -d' ' -f1)
BUS_VALUE="/dev/bus/usb/$BUS/$DEV"

echo "MAC_ADDRESS=${MAC_ADDRESS}" > .env-cloud
echo "RTL_SDR_BUS=${BUS_VALUE}" >> .env-cloud
echo "CLOUD_API_HOST=api.loctio.com" >> .env-cloud
echo "ECR=810204744368.dkr.ecr.eu-central-1.amazonaws.com" >> .env-cloud

loctio_ue_raspbian.sh
docker-compose --env-file .env-cloud -f docker-compose.yml down
docker-compose --env-file .env-cloud -f docker-compose.yml --compatibility up -d loctio_ue_arm
docker logs -f loctio_ue
