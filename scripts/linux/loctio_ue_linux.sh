AWS_ID="810204744368"
AWS_REGION="eu-central-1"
AWS_ECR_DOMAIN="$AWS_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
AWS_ACCESS_KEY_ID=AKIA3ZI7XJKYLF25JANE
AWS_SECRET_ACCESS_KEY=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 

aws configure set profile.loctio.region $AWS_REGION
aws configure set profile.loctio.aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set profile.loctio.aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws --profile loctio ecr get-login --no-include-email > aws_login.sh && chmod +x aws_login.sh && ./aws_login.sh; docker pull $AWS_ECR_DOMAIN/loctio_ue_x86_64:latest
