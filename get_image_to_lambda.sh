#!/bin/bash
set -e

LIST_LAMBDAS="$1"
LIST_ECR="$2"
NEW_VERSION_TAG="$3"
USER="$4"

echo $LIST_LAMBDAS > lambdas.json
echo $LIST_ECR > ecr.json
mapfile -t lambdas < <(jq -c '.[]' lambdas.json)

if [ -f success_lambdas.json ]; then
    existingJson=$(cat success_lambdas.json)
else
    existingJson='{}'
fi

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

    updatedJson=$(echo "$existingJson" | jq --arg user "$USER" --argjson lambdas "$successfulUpdatesJson" \
                '.[$user] = $lambdas')
    echo "$updatedJson" > success_lambdas.json
done

rm lambdas.json
rm ecr.json