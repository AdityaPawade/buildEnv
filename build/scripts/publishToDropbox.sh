#!/bin/bash -x

MODULE="$1"
REFRESH_TOKEN="$2"
APP_KEY="$3"
APP_SECRET="$4"

LOCAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "local dir : $LOCAL_DIR"
ROOT_DIR="$MOUNT_DIR"
echo "root dir : $ROOT_DIR"

function exec_there() {
  DIR="$1"
  shift
  (cd "$DIR" || exit; "$@")
}

function get_file_store_access_token() {
  
  response=$(curl https://api.dropbox.com/oauth2/token \
    -d grant_type=refresh_token \
    -d refresh_token="$REFRESH_TOKEN" \
    -u "$APP_KEY":"$APP_SECRET")
  token=$(echo "$response" | cut -d' ' -f4 | cut -d'"' -f2)
  echo "$token"
}

function publish_app() {
  
  exec_there "$ROOT_DIR/dist" zip -vr "$MODULE.zip" "server" -x "*.DS_Store"
  token=$(get_file_store_access_token)
  curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $token" \
    --header "Dropbox-API-Arg: {\"path\": \"/releases/$MODULE.zip\",\"mode\": \"overwrite\",\"autorename\": false,\"mute\": false,\"strict_conflict\": false}" \
    --header "Content-Type: application/octet-stream" \
    --data-binary @"$ROOT_DIR"/dist/"$MODULE".zip
  rm -rf "$ROOT_DIR"/dist/"$MODULE".zip
}

publish_app