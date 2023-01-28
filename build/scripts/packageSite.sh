#!/bin/bash -x

APP="$1"
ENV="$2"
MODULE="$3"
REPO_NAME=$4

LOCAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "local dir : $LOCAL_DIR"
BUILD_ROOT_DIR="$LOCAL_DIR/.."
BUILD_ENV_ROOT_DIR="$LOCAL_DIR/../.."
ROOT_DIR="$MOUNT_DIR"
echo "root dir : $ROOT_DIR"

function exec_there() {
  DIR="$1"
  shift
  (cd "$DIR" || exit; "$@")
}
  
rm -rf "$ROOT_DIR"/dist
mkdir -p "$ROOT_DIR"/dist/$APP/"$MODULE"

cp -R "$ROOT_DIR"/site/$MODULE/dist/* "$ROOT_DIR"/dist/$APP/"$MODULE"/
cp -R "$ROOT_DIR"/conf/prod/$MODULE.properties "$ROOT_DIR"/dist/nginx.conf

cp "$BUILD_ROOT_DIR"/env/buster-nginx-app/Dockerfile "$ROOT_DIR"/dist

docker buildx build  \
   --cache-from type=local,src="$BUILD_ENV_ROOT_DIR"/buildx-cache,mode=max \
   --cache-to type=local,dest="$BUILD_ENV_ROOT_DIR"/buildx-cache,mode=max \
   --platform linux/arm64 --build-arg APP_NAME="$APP" --build-arg ARCH=aarch64 \
   -t "$REPO_NAME" "$ROOT_DIR"/dist/ --no-cache --push

rm -rf "$ROOT_DIR"/dist