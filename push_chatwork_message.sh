CHATWORK_API_TOKEN="$1"
CHATWORK_ROOM_ID="$2"
BODY="$3"
ENCODED_BODY=$(echo "$BODY" | jq -sRr @uri)

curl -k -X POST -H "X-ChatWorkToken: ${CHATWORK_API_TOKEN}" -d "body=${ENCODED_BODY}" "https://api.chatwork.com/v2/rooms/${CHATWORK_ROOM_ID}/messages"
