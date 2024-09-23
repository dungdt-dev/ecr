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

docker run -it -d --name ${IMAGE_NAME} ${IMAGE_NAME}:${NEW_VERSION_TAG} sh

docker exec ${IMAGE_NAME} sh -c "
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
						cp -r build/* deploy/ &&
						cd deploy &&
						if [ -n \"\$(git status --porcelain)\" ]; then
              git add . &&
              git commit -m '${NEW_VERSION_TAG}' &&
              git push
            else
                echo 'No changes to commit'
            fi
            " || exit 1

docker rm -f ${IMAGE_NAME}
docker rmi ${IMAGE_NAME}:${NEW_VERSION_TAG}
rm -rf build/