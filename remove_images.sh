#!/bin/bash

if [[ -f "images.json" ]]; then
    mapfile -t images < <(jq -r '.[]' images.json)

    for image in "${images[@]}"; do
        if [[ "$(docker images -q $image 2> /dev/null)" != "" ]]; then
            docker rmi $image || true
        fi
    done

    rm -f images.json
fi
