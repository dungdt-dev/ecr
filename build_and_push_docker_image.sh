#!/bin/bash

LIST_ECR="$1"
NEW_VERSION_TAG="$2"

# Remove front end
rm -rf build/

echo $LIST_ECR > ecr.json
mapfile -t list_ecr < <(jq -c '.[]' ecr.json)
rm ecr.json

# Khởi tạo file JSON để lưu trữ các image đã build thành công
images_file="images.json"
if [[ ! -f $images_file ]]; then
    echo "[]" > $images_file
fi

successfulImages=()

for ecr in "${list_ecr[@]}"; do
    ecr_uri=$(echo "$ecr" | jq -r '.ecr_uri')
    repository=$(echo "$ecr" | jq -r '.repository')
    region=$(echo "$ecr" | jq -r '.region')

    # Kiểm tra nếu image đã tồn tại
    if [[ "$(docker images -q ${repository}:${NEW_VERSION_TAG} 2> /dev/null)" == "" ]]; then
        docker build -t ${repository}:${NEW_VERSION_TAG} .
    fi

    # Set tag
    docker tag ${repository}:${NEW_VERSION_TAG} ${ecr_uri}/${repository}:${NEW_VERSION_TAG}

    # Log in to Amazon ECR
    aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${ecr_uri}

    # Push Docker image to Amazon ECR
    docker push ${ecr_uri}/${repository}:${NEW_VERSION_TAG}

    # Thêm image vào danh sách đã build thành công
    successfulImages+=("${repository}:${NEW_VERSION_TAG}")

    # Ghi danh sách image vào file JSON
    successfulImagesJson=$(printf '%s\n' "${successfulImages[@]}" | jq -s '.')

    echo "$successfulImagesJson" > $images_file

    # Remove image tag
    docker rmi ${ecr_uri}/${repository}:${NEW_VERSION_TAG}
done