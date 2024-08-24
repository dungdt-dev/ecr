#!/bin/bash
LIST_LAMBDAS="$1"
ECR="$2"
NEW_VERSION_TAG="$3"
ECR_URI=$(echo "$ECR" | jq -r '.ecr_uri')
IMAGE_NAME=$(echo "$ECR" | jq -r '.name')

# Chia danh sách các hàm Lambda bằng dấu phẩy
IFS=',' read -r -a array <<< "$LIST_LAMBDAS"

# Lặp qua từng phần tử trong danh sách
for element in "${array[@]}"
do
    IFS=':' read -r -a lambda <<< "$element"
    name="${lambda[0]}"
    region="${lambda[1]}"

   aws lambda update-function-code \
   --function-name $name \
   --image-uri ${ECR_URI}/${IMAGE_NAME}:${NEW_VERSION_TAG} --region $region
done