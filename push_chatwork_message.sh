CHATWORK_API_TOKEN="$1"
CHATWORK_ROOM_ID="$2"
BODY="$3"

curl -k -X POST -H"X-ChatWorkToken: ${CHATWORK_API_TOKEN}" -d "body=${BODY}" "https://api.chatwork.com/v2/rooms/${CHATWORK_API_TOKEN}/messages"
