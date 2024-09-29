#!/bin/bash
ECR="$1"
IMAGE_NAME=$(echo "$ECR" | jq -r '.name')
REGION=$(echo "$ECR" | jq -r '.region')

NEW_VERSION_TAG="$2"

GIT="$3"
USER_NAME=$(echo "$GIT" | jq -r '.name')
USER_EMAIL=$(echo "$GIT" | jq -r '.email')
REMOTE_ORIGIN=$(echo "$GIT" | jq -r '.remote_origin')
BRANCH=$(echo "$GIT" | jq -r '.branch')

# restore
git restore .
git checkout .

#build
docker build -t ${IMAGE_NAME}:${NEW_VERSION_TAG} .

docker run -it -d --name ${IMAGE_NAME} ${IMAGE_NAME}:${NEW_VERSION_TAG} sh

exec_result=$(docker exec ${IMAGE_NAME} sh -c "
						git config --global init.defaultBranch master &&
						mkdir deploy &&
                        cd deploy &&
                        git init &&
						git config --global user.name '${USER_NAME}' &&
						git config --global user.email '${USER_EMAIL}' &&
                        git remote add origin ${REMOTE_ORIGIN} &&
                        git remote -v &&
						git fetch &&
						git checkout ${BRANCH} &&
						cd /var/task &&
						cp -r build1/* deploy/ &&
						cd deploy &&
						if [ -n \"\$(git status --porcelain)\" ]; then
              git add . &&
              git commit -m '${NEW_VERSION_TAG}' &&
              git push
            else
                echo 'No changes to commit'
            fi
            ")

docker rm -f ${IMAGE_NAME}
docker rmi ${IMAGE_NAME}:${NEW_VERSION_TAG}


# error
if [ $? -ne 0 ]; then
    echo "Error occurred during docker exec: $exec_result"
        exit 1
fi