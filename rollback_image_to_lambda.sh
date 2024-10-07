#!/bin/bash
set -e

LIST_ECR="$1"
OLD_VERSION_TAG="$2"

echo $LIST_ECR > ecr.json

if [ -f "success_lambdas.json" ]; then
    mapfile -t lambdas < <(jq -c '.[]' success_lambdas.json)

    for lambda in "${lambdas[@]}"; do
        name=$(echo "$lambda" | jq -r '.name')
        region=$(echo "$lambda" | jq -r '.region')

        matching_ecr=$(jq -c --arg region "$region" '.[] | select(.region == $region)' ecr.json)

            if [[ -n "$matching_ecr" ]]; then
                ecr_uri=$(echo "$matching_ecr" | jq -r '.ecr_uri')
                repository=$(echo "$matching_ecr" | jq -r '.repository')
            fi

        sleep 10

        status=$(aws lambda get-function \
                    --function-name $name \
                    --region $region | jq -r '.Configuration.LastUpdateStatus') || exit 1

        if [ "$status" == "InProgress" ]; then
            while [ "$status" == "InProgress" ]; do
                sleep 10
                status=$(aws lambda get-function \
                            --function-name $name \
                            --region $region | jq -r '.Configuration.LastUpdateStatus') || exit 1
            done
        fi

        aws lambda update-function-code \
           --function-name $name \
           --image-uri ${ecr_uri}/${repository}:${OLD_VERSION_TAG} --region $region > /dev/null 2>&1 || exit 1
    done
fi

rm ecr.json