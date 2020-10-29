#!/bin/bash

set -e

echo "Logging in to ECR"
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $(aws sts get-caller-identity | jq ".Account" | tr -d '"' ).dkr.ecr.eu-west-1.amazonaws.com

echo "Getting image name"
image_name=$(aws sts get-caller-identity | jq ".Account" | tr -d '"' ).dkr.ecr.eu-west-1.amazonaws.com/backend:latest

echo "Building image"
docker build -t $image_name .

echo "Pushing to ECR"
docker push $image_name