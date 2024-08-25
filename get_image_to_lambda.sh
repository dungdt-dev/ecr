#!/bin/bash
set -e

LIST_LAMBDAS="$1"
ECR="$2"
NEW_VERSION_TAG="$3"
ECR_URI=$(echo "$ECR" | jq -r '.ecr_uri')
IMAGE_NAME=$(echo "$ECR" | jq -r '.name')

echo $LIST_LAMBDAS > lambdas.json
mapfile -t lambdas < <(jq -c '.[]' lambdas.json)
rm lambdas.json

successfulUpdates=()

for lambda in "${lambdas[@]}"; do
    name=$(echo "$lambda" | jq -r '.name')
    region=$(echo "$lambda" | jq -r '.region')

    aws lambda update-function-code \
       --function-name $name \
       --image-uri ${ECR_URI}/${IMAGE_NAME}:${NEW_VERSION_TAG} --region $region || exit 1

    successfulUpdates+=("$lambda")
    successfulUpdatesJson=$(printf '%s\n' "${successfulUpdates[@]}" | jq -s '.')

    echo "$successfulUpdatesJson" > success_lambdas.json
done