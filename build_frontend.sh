#!/bin/bash
NEW_VERSION_TAG="$1"
GIT="$2"

USER_NAME=$(echo "$GIT" | jq -r '.name')
USER_EMAIL=$(echo "$GIT" | jq -r '.email')
REMOTE_ORIGIN=$(echo "$GIT" | jq -r '.remote_origin')
BRANCH=$(echo "$GIT" | jq -r '.branch')

# restore
git restore .
git checkout .

# build
docker build -t front-end:${NEW_VERSION_TAG} .

docker run -it -d --name front-end front-end:${NEW_VERSION_TAG} sh

exec_result=$(docker exec front-end sh -c "
                        git config --global init.defaultBranch master &&
                        mkdir deploy &&
                        cd deploy &&
                        git init &&
                        git config --global user.name '${USER_NAME}' &&
                        git config --global user.email '${USER_EMAIL}' &&
                        git remote add origin ${REMOTE_ORIGIN} &&
                        git remote -v &&
                        git fetch &&
                        # Check if branch with NEW_VERSION_TAG exists
                        if git show-ref --quiet refs/heads/${NEW_VERSION_TAG}; then
                          git checkout ${NEW_VERSION_TAG} &&
                          git pull ${NEW_VERSION_TAG} &&
                          git push -f origin ${NEW_VERSION_TAG}:${BRANCH}
                        else
                          git checkout ${BRANCH} &&
                          # Check if there are changes to commit before pushing
                          cd /var/task &&
                          cp -r build/* deploy/ &&
                          cd deploy &&
                          if [ -n \"\$(git status --porcelain)\" ]; then
                            git add . &&
                            git commit -m '${NEW_VERSION_TAG}' &&
                            git push
                          fi
                          git checkout -b ${NEW_VERSION_TAG} &&
                          git push origin ${NEW_VERSION_TAG}
                        fi
            ") || exec_result=1

docker rm -f front-end
docker rmi front-end:${NEW_VERSION_TAG}

# error handling
if [ $exec_result -ne 0 ]; then
    echo "An error occurred during the exec command."
    exit 1
fi
