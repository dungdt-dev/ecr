#!/bin/bash
set -e

LIST_LAMBDAS="$1"
LIST_ECR="$2"
NEW_VERSION_TAG="$3"

echo $LIST_LAMBDAS > lambdas.json
mapfile -t lambdas < <(jq -c '.[]' lambdas.json)
rm lambdas.json

echo $LIST_ECR > ecr.json

successfulUpdates=()

for lambda in "${lambdas[@]}"; do
    name=$(echo "$lambda" | jq -r '.name')
    region=$(echo "$lambda" | jq -r '.region')

    matching_ecr=$(jq -c --arg region "$region" '.[] | select(.region == $region)' ecr.json)

    if [[ -n "$matching_ecr" ]]; then
        ecr_uri=$(echo "$matching_ecr" | jq -r '.ecr_uri')
        repository=$(echo "$matching_ecr" | jq -r '.repository')
    fi

    aws lambda update-function-code \
       --function-name $name \
       --image-uri ${ecr_uri}/${repository}:${NEW_VERSION_TAG} --region $region > /dev/null 2>&1 || exit 1

    successfulUpdates+=("$lambda")
    successfulUpdatesJson=$(printf '%s\n' "${successfulUpdates[@]}" | jq -s '.')

    echo "$successfulUpdatesJson" > success_lambdas.json
done

rm ecr.json