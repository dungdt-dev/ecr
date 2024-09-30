#!/bin/bash
#ECR="$1"
#NEW_VERSION_TAG="$2"
#ECR_URI=$(echo "$ECR" | jq -r '.ecr_uri')
#IMAGE_NAME=$(echo "$ECR" | jq -r '.name')
#REGION=$(echo "$ECR" | jq -r '.region')
#
##Remove front end
#rm -rf build/
#
##Build
#docker build -t ${IMAGE_NAME}:${NEW_VERSION_TAG} .
#
##Set tag
#docker tag ${IMAGE_NAME}:${NEW_VERSION_TAG} ${ECR_URI}/${IMAGE_NAME}:${NEW_VERSION_TAG}
#
##Log in to Amazon ECR
#aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_URI}
#
##Push Docker image to Amazon ECR
#docker push ${ECR_URI}/${IMAGE_NAME}:${NEW_VERSION_TAG}
#
##Remove image
#docker rmi ${IMAGE_NAME}:${NEW_VERSION_TAG}
#docker rmi ${ECR_URI}/${IMAGE_NAME}:${NEW_VERSION_TAG}

LIST_ECR="$1"
NEW_VERSION_TAG="$2"

#Remove front end
rm -rf build/

echo $LIST_ECR > ecr.json
mapfile -t list_ecr < <(jq -c '.[]' ecr.json)
rm ecr.json

for ecr in "${list_ecr[@]}"; do
    ecr_uri=$(echo "$ecr" | jq -r '.ecr_uri')
    repository=$(echo "$ecr" | jq -r '.repository')
    region=$(echo "$ecr" | jq -r '.region')

    #Build
    docker build -t ${repository}:${NEW_VERSION_TAG} .

    #Set tag
    docker tag ${repository}:${NEW_VERSION_TAG} ${ecr_uri}/${repository}:${NEW_VERSION_TAG}

    #Log in to Amazon ECR
    aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${ecr_uri}

    #Push Docker image to Amazon ECR
    docker push ${ecr_uri}/${repository}:${NEW_VERSION_TAG}

    #Remove image
    docker rmi ${repository}:${NEW_VERSION_TAG}
    docker rmi ${ecr_uri}/${repository}:${NEW_VERSION_TAG}
done