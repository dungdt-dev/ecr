#!/bin/bash

LIST_ECR="$1"
NEW_VERSION_TAG="$2"

# Remove front end
rm -rf build/

echo $LIST_ECR > ecr.json
mapfile -t list_ecr < <(jq -c '.[]' ecr.json)
rm ecr.json

images_file="images.json"
if [[ ! -f $images_file ]]; then
    echo "[]" > $images_file
fi

successfulImages=$(jq -c '.' $images_file)

for ecr in "${list_ecr[@]}"; do
    ecr_uri=$(echo "$ecr" | jq -r '.ecr_uri')
    repository=$(echo "$ecr" | jq -r '.repository')
    region=$(echo "$ecr" | jq -r '.region')

    if [[ "$(docker images -q ${repository}:${NEW_VERSION_TAG} 2> /dev/null)" == "" ]]; then
        docker build -t ${repository}:${NEW_VERSION_TAG} .
    fi

    # Set tag
    docker tag ${repository}:${NEW_VERSION_TAG} ${ecr_uri}/${repository}:${NEW_VERSION_TAG}

    # Log in to Amazon ECR
    aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${ecr_uri}

    # Push Docker image to Amazon ECR
    docker push ${ecr_uri}/${repository}:${NEW_VERSION_TAG}

    successfulImages=$(echo $successfulImages | jq --arg image "${repository}:${NEW_VERSION_TAG}" '. += [$image]')
    echo "$successfulImages" > $images_file

    # Remove image tag
    docker rmi ${ecr_uri}/${repository}:${NEW_VERSION_TAG}
done