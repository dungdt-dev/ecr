#!/bin/bash
set -e

LIST_LAMBDAS="$1"
LIST_ECR="$2"
OLD_VERSION_TAG="$3"

echo $LIST_LAMBDAS > lambdas.json
echo $LIST_ECR > ecr.json

mapfile -t lambdas < <(jq -c '.[]' lambdas.json)

for lambda in "${lambdas[@]}"; do
    name=$(echo "$lambda" | jq -r '.name')
    region=$(echo "$lambda" | jq -r '.region')

    matching_ecr=$(jq -c --arg region "$region" '.[] | select(.region == $region)' ecr.json)

        if [[ -n "$matching_ecr" ]]; then
            ecr_uri=$(echo "$matching_ecr" | jq -r '.ecr_uri')
            repository=$(echo "$matching_ecr" | jq -r '.repository')
        fi

    sleep 5

    status=$(aws lambda get-function \
                --function-name $name \
                --region $region | jq -r '.Configuration.LastUpdateStatus') || exit 1

    if [ "$status" == "InProgress" ]; then
        while [ "$status" == "InProgress" ]; do
            sleep 5
            status=$(aws lambda get-function \
                        --function-name $name \
                        --region $region | jq -r '.Configuration.LastUpdateStatus') || exit 1
        done
    fi

    aws lambda update-function-code \
       --function-name $name \
       --image-uri ${ecr_uri}/${repository}:${OLD_VERSION_TAG} --region $region > /dev/null 2>&1 || exit 1
done

rm ecr.json