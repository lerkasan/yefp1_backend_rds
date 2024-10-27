#!/bin/bash
set -xe

APPLICATION_NAME="yefp1"
DEPLOYMENT_GROUP_NAME="stage"
CORS_ALLOWED_ORIGINS="http://localhost"
DEBUG=False
DB_PORT=5432

AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
export AWS_REGION="${AWS_REGION:-us-east-1}"

AWS_ACCOUNT_ID=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .accountId)

DEPLOYMENT_ID=$(aws deploy list-deployments --application-name "$APPLICATION_NAME" --deployment-group-name "$DEPLOYMENT_GROUP_NAME" --region "$AWS_REGION" --include-only-statuses "InProgress" --query "deployments[0]" --output text --no-paginate)

COMMIT_SHA=$(aws deploy get-deployment --deployment-id "$DEPLOYMENT_ID" --query "deploymentInfo.revision.gitHubLocation.commitId" --output text)

BACKEND_RDS_TAG="${COMMIT_SHA:-latest}"

DB_HOST=$(aws ssm get-parameter --region "$AWS_REGION" --name "${APPLICATION_NAME}_database_host" --with-decryption --query Parameter.Value --output text)
DB_NAME=$(aws ssm get-parameter --region "$AWS_REGION" --name "${APPLICATION_NAME}_database_name" --with-decryption --query Parameter.Value --output text)
DB_USER=$(aws ssm get-parameter --region "$AWS_REGION" --name "${APPLICATION_NAME}_database_username" --with-decryption --query Parameter.Value --output text)
DB_PASSWORD=$(aws ssm get-parameter --region "$AWS_REGION" --name "${APPLICATION_NAME}_database_password" --with-decryption --query Parameter.Value --output text)
SECRET_KEY=$(aws ssm get-parameter --region "$AWS_REGION" --name "${APPLICATION_NAME}_api_secret_key" --with-decryption --query Parameter.Value --output text)

export DB_HOST="$DB_HOST"
export DB_NAME="$DB_NAME"
export DB_USER="$DB_USER"
export DB_PASSWORD="$DB_PASSWORD"
export DB_PORT="$DB_PORT"

export SECRET_KEY="$SECRET_KEY"
export CORS_ALLOWED_ORIGINS="$CORS_ALLOWED_ORIGINS"
export DEBUG="$DEBUG"

export BACKEND_RDS_TAG="${BACKEND_RDS_TAG:-latest}"
export AWS_ACCOUNT_ID="$AWS_ACCOUNT_ID"

cd /home/ubuntu/app || exit
docker compose up -d
