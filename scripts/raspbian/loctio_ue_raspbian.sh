AWS_ID="810204744368" AWS_REGION="eu-central-1"
AWS_ECR_DOMAIN="$AWS_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
AWS_ACCESS_KEY_ID=AKIA3ZI7XJKYLF25JANE
AWS_SECRET_ACCESS_KEY=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 aws ecr get-login --
region eu-central-1 --no-include-email > aws_login.sh && chmod +x aws_login.sh && ./aws_login.sh; docker
pull $AWS_ECR_DOMAIN/loctio_ue_arm:latest
