#!/bin/bash
set -xe

APPLICATION_NAME="yefp1"
DEPLOYMENT_GROUP_NAME="stage"

AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
export AWS_REGION="${AWS_REGION:-us-east-1}"

AWS_ACCOUNT_ID=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .accountId)

DEPLOYMENT_ID=$(aws deploy list-deployments --application-name "$APPLICATION_NAME" --deployment-group-name "$DEPLOYMENT_GROUP_NAME" --region "$AWS_REGION" --include-only-statuses "InProgress" --query "deployments[0]" --output text --no-paginate)

COMMIT_SHA=$(aws deploy get-deployment --deployment-id "$DEPLOYMENT_ID" --query "deploymentInfo.revision.gitHubLocation.commitId" --output text)

BACKEND_RDS_TAG="${COMMIT_SHA:-latest}"

export BACKEND_RDS_TAG="${BACKEND_RDS_TAG:-latest}"
export AWS_ACCOUNT_ID="$AWS_ACCOUNT_ID"

cd /home/ubuntu/app || exit

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

docker compose pull