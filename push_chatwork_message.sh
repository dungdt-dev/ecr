#!/bin/bash
CHATWORK_CREDENTIAL="$1"
CHATWORK_API_TOKEN=$(echo "$CHATWORK_CREDENTIAL" | jq -r '.api_token')
CHATWORK_ROOM_ID=$(echo "$CHATWORK_CREDENTIAL" | jq -r '.room_id')
BODY="$2"

curl -k -X POST -H "X-ChatWorkToken: ${CHATWORK_API_TOKEN}" -d "body=${BODY}" "https://api.chatwork.com/v2/rooms/${CHATWORK_ROOM_ID}/messages"
