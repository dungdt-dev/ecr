#!/bin/bash
set -e

LIST_LAMBDAS="$1"
NEW_VERSION_TAG="$2"
USER="$3"

echo $LIST_LAMBDAS > lambdas.json
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
    ecr_uri=$(echo "$lambda" | jq -r '.ecr_uri')

    aws lambda update-function-code \
       --function-name $name \
       --image-uri ${ecr_uri}:${NEW_VERSION_TAG} --region $region > /dev/null 2>&1 || exit 1

    successfulUpdates+=("$lambda")
    successfulUpdatesJson=$(printf '%s\n' "${successfulUpdates[@]}" | jq -s '.')

    updatedJson=$(echo "$existingJson" | jq --arg user "$USER" --argjson lambdas "$successfulUpdatesJson" \
                '.[$user] = $lambdas')
    echo "$updatedJson" > success_lambdas.json
done

rm lambdas.json