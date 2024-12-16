#!/bin/bash
set -e

LIST_LAMBDAS="$1"
OLD_VERSION_TAG="$2"

echo $LIST_LAMBDAS > lambdas.json

mapfile -t lambdas < <(jq -c '.[]' lambdas.json)

for lambda in "${lambdas[@]}"; do
    name=$(echo "$lambda" | jq -r '.name')
    region=$(echo "$lambda" | jq -r '.region')
    ecr_uri=$(echo "$lambda" | jq -r '.ecr_uri')

    sleep 3

    status=$(aws lambda get-function \
                --function-name $name \
                --region $region | jq -r '.Configuration.LastUpdateStatus') || exit 1

    if [ "$status" == "InProgress" ]; then
        while [ "$status" == "InProgress" ]; do
            sleep 3
            status=$(aws lambda get-function \
                        --function-name $name \
                        --region $region | jq -r '.Configuration.LastUpdateStatus') || exit 1
        done
    fi

    aws lambda update-function-code \
       --function-name $name \
       --image-uri ${ecr_uri}:${OLD_VERSION_TAG} --region $region > /dev/null 2>&1 || exit 1
done