#!/bin/bash

# Đọc file images.json
if [[ -f "images.json" ]]; then
    mapfile -t images < <(jq -r '.[]' images.json)

    # Xóa tất cả các image trong danh sách
    for image in "${images[@]}"; do
        docker rmi $image || true  # Không dừng lại nếu gặp lỗi
    done

    # Xóa file sau khi hoàn thành
    rm -f images.json
fi
