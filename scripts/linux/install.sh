#!/bin/bash

ETHIF="ens32"
AWS_ID="810204744368"
AWS_REGION="eu-central-1"
AWS_ECR_DOMAIN="$AWS_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

curl -fsSL -o docker-compose.yml https://raw.githubusercontent.com/loctio/lcf/master/scripts/linux/docker-compose.yml 

echo -n "AWS_ACCESS_KEY_ID: "
read access_key
echo -n "AWS_SECRET_ACCESS_KEY: "
read secret_access_key

AWS_ACCESS_KEY_ID=$access_key
AWS_SECRET_ACCESS_KEY=$secret_access_key

MAC_ADDRESS=$(ip link show $ETHIF | awk '/ether/ {print $2}')
echo "MAC_ADDRESS=${MAC_ADDRESS}" > .env-cloud
echo "CLOUD_API_HOST=api.loctio.com" >> .env-cloud
echo "ECR=$AWS_ECR_DOMAIN" >> .env-cloud

aws configure set profile.loctio.region $AWS_REGION
aws configure set profile.loctio.aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set profile.loctio.aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws --profile loctio ecr get-login --no-include-email > aws_login.sh && chmod +x aws_login.sh && ./aws_login.sh; docker pull $AWS_ECR_DOMAIN/loctio_ue_x86_64:latest

docker-compose --env-file .env-cloud -f docker-compose.yml down
docker-compose --env-file .env-cloud -f docker-compose.yml --compatibility up -d loctio_ue_x86_64
docker logs -f loctio_ue