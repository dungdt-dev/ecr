#!/bin/bash
set -e

LAMBDA_TEST="$1"
name=$(echo "$LAMBDA_TEST" | jq -r '.name')
region=$(echo "$LAMBDA_TEST" | jq -r '.region')
url=$(echo "$LAMBDA_TEST" | jq -r '.url')
text=$(echo "$LAMBDA_TEST" | jq -r '.text')

LIST_ECR="$2"
NEW_VERSION_TAG="$3"

echo $LIST_ECR > ecr.json

matching_ecr=$(jq -c --arg region "$region" '.[] | select(.region == $region)' ecr.json)
if [[ -n "$matching_ecr" ]]; then
ecr_uri=$(echo "$matching_ecr" | jq -r '.ecr_uri')
repository=$(echo "$matching_ecr" | jq -r '.repository')
fi
rm ecr.json

aws lambda update-function-code \
--function-name $name \
--image-uri ${ecr_uri}/${repository}:${NEW_VERSION_TAG} --region $region || exit 1

sleep 30

curl -s "$url" > response.txt

if grep -q "$text" response.txt; then
  echo "Text '$text' found in response"
  exit 0
else
  echo "Text '$text' not found in response"
  exit 1
fi
