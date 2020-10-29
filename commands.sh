#!/bin/bash

# get EKS kubeconfig
aws eks --region $(cd ./terraform && terraform output region) update-kubeconfig --name $(cd ./terraform && terraform output cluster_name)

# login to ECR
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $(aws sts get-caller-identity | jq ".Account" | tr -d '"' ).dkr.ecr.eu-west-1.amazonaws.com

# get LB after deploy
kubectl get svc frontend --output jsonpath='{.status.loadBalancer.ingress[0].hostname}' | pbcopy

# run local environmet
skaffold dev --port-forward=true