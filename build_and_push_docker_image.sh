#!/bin/bash
ECR="$1"
NEW_VERSION_TAG="$2"
ECR_URI=$(echo "$ECR" | jq -r '.ecr_uri')
IMAGE_NAME=$(echo "$ECR" | jq -r '.name')
REGION=$(echo "$ECR" | jq -r '.region')

#Remove front end
rm -rf build/

#Build
docker build -t ${IMAGE_NAME}:${NEW_VERSION_TAG} .

#Set tag
docker tag ${IMAGE_NAME}:${NEW_VERSION_TAG} ${ECR_URI}/${IMAGE_NAME}:${NEW_VERSION_TAG}

#Log in to Amazon ECR
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_URI}

#Push Docker image to Amazon ECR
docker push ${ECR_URI}/${IMAGE_NAME}:${NEW_VERSION_TAG}

#Remove image
#docker rmi ${IMAGE_NAME}:${NEW_VERSION_TAG}