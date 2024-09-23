#!/bin/bash
ECR="$1"
NEW_VERSION_TAG="$2"
IMAGE_NAME=$(echo "$ECR" | jq -r '.name')
REGION=$(echo "$ECR" | jq -r '.region')

#build
docker build -t ${IMAGE_NAME}:${NEW_VERSION_TAG} .