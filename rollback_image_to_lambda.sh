#!/bin/bash
set -e

ECR="$1"
OLD_VERSION_TAG="$2"
ECR_URI=$(echo "$ECR" | jq -r '.ecr_uri')
IMAGE_NAME=$(echo "$ECR" | jq -r '.name')

if [ -f "success_lambdas.json" ]; then
    mapfile -t lambdas < <(jq -c '.[]' success_lambdas.json)

    for lambda in "${lambdas[@]}"; do
        name=$(echo "$lambda" | jq -r '.name')
        region=$(echo "$lambda" | jq -r '.region')

        status=$(aws lambda get-function \
                    --function-name $name \
                    --region $region | jq -r '.Configuration.LastUpdateStatus')

        if [ "$status" == "InProgress" ]; then
            while [ "$status" == "InProgress" ]; do
                sleep 10
                status=$(aws lambda get-function \
                            --function-name $name \
                            --region $region | jq -r '.Configuration.LastUpdateStatus')
            done
        fi

        aws lambda update-function-code \
           --function-name $name \
           --image-uri ${ECR_URI}/${IMAGE_NAME}:${OLD_VERSION_TAG} --region $region || exit 1
    done
fi