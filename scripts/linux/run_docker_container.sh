#!/bin/bash

MAC_ADDRESS=$(ip link show ens32 | awk '/ether/ {print $2}')
echo "MAC_ADDRESS=${MAC_ADDRESS}" > .env-cloud
echo "CLOUD_API_HOST=loctio-api.ddns.net" >> .env-cloud
echo "ECR=810204744368.dkr.ecr.eu-central-1.amazonaws.com" >> .env-cloud

docker-compose --env-file .env-cloud -f docker-compose.yml down
docker-compose --env-file .env-cloud -f docker-compose.yml --compatibility up -d loctio_ue_x86_64
docker logs -f loctio_ue
