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
                        git config --global init.defaultBranch main &&
                        mkdir deploy &&
                        cd deploy &&
                        git init &&
                        git config --global user.name '${USER_NAME}' &&
                        git config --global user.email '${USER_EMAIL}' &&
                        git remote add origin ${REMOTE_ORIGIN} &&
                        git remote -v &&
                        git fetch &&
                        git checkout ${BRANCH} &&
                        git fetch --tags &&
                        # Check if tag with NEW_VERSION_TAG exists
                        if git tag -l | grep -q \"^${NEW_VERSION_TAG}\$\"; then
                          git reset --hard ${NEW_VERSION_TAG} &&
                          git push origin ${BRANCH} -f
                        else
                          cd /var/task/deploy &&
                          for item in *; do
                            if [ \"\$item\" != \".git\" ]; then
                                rm -rf \"\$item\"
                            fi
                          done

                          # Copy files from build to deploy folder
                          cd /var/task &&
                          cp -r build/* deploy/ &&
                          cd deploy &&
                          # Replace URLs in index.html
                          if [[ -f index.html ]]; then
                            sed -i 's#\(css/.*\.css\)#https://cdn.jsdelivr.net/gh/dungdt-dev/js-delivery@$NEW_VERSION_TAG/\1#g' index.html &&
                            sed -i 's#\(js/.*\.js\)#https://cdn.jsdelivr.net/gh/dungdt-dev/js-delivery@$NEW_VERSION_TAG/\1#g' index.html
                          fi &&

                          # Check if there are changes to commit before pushing
                          if [ -n \"\$(git status --porcelain)\" ]; then
                            git add . &&
                            git commit -m '${NEW_VERSION_TAG}' &&
                            git push
                          fi
                          git tag ${NEW_VERSION_TAG} &&
                          git push --tags
                        fi
            ") || exec_result=1

docker rm -f front-end
docker rmi front-end:${NEW_VERSION_TAG}

# error handling
if [ $exec_result -ne 0 ]; then
    echo "An error occurred during the exec command."
    exit 1
fi
