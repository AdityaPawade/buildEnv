#!/bin/bash -x

APP="$1"
ENV="$2"
MODULE="$3"
VERSION="$4"
PACKAGED_JAR_NAME="$5"
REPO_NAME=$6

LOCAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "local dir : $LOCAL_DIR"
BUILD_ROOT_DIR="$LOCAL_DIR/.."
BUILD_ENV_ROOT_DIR="$LOCAL_DIR/../.."
ROOT_DIR="$MOUNT_DIR"
echo "root dir : $ROOT_DIR"
JAR_FILE="$ROOT_DIR/$MODULE/target/$MODULE-$VERSION-$ENV.jar"
echo "jar file : $JAR_FILE"

function exec_there() {
  DIR="$1"
  shift
  (cd "$DIR" || exit; "$@")
}
  
rm -rf "$ROOT_DIR"/dist
mkdir -p "$ROOT_DIR"/dist/"$APP"
mkdir -p "$ROOT_DIR"/dist/"$APP"/bin
mkdir -p "$ROOT_DIR"/dist/"$APP"/lib
mkdir -p "$ROOT_DIR"/dist/"$APP"/conf
# mkdir -p "$ROOT_DIR"/dist/"$APP"/site
mkdir -p "$ROOT_DIR"/dist/"$APP"/run

cp "$JAR_FILE" "$ROOT_DIR"/dist/"$APP"/lib/"$PACKAGED_JAR_NAME".jar

cp -R "$ROOT_DIR"/bin/* "$ROOT_DIR"/dist/"$APP"/bin/
cp -R "$ROOT_DIR"/conf/prod/* "$ROOT_DIR"/dist/"$APP"/conf/
# cp -R "$ROOT_DIR"/site/* "$ROOT_DIR"/dist/"$APP"/site/

cp "$BUILD_ROOT_DIR"/env/buster-graalvm-app/Dockerfile "$ROOT_DIR"/dist

docker buildx build  \
   --cache-from type=local,src="$BUILD_ENV_ROOT_DIR"/buildx-cache,mode=max \
   --cache-to type=local,dest="$BUILD_ENV_ROOT_DIR"/buildx-cache,mode=max \
   --platform linux/arm64 --build-arg APP_NAME="$APP" --build-arg ARCH=aarch64 \
   -t "$REPO_NAME" "$ROOT_DIR"/dist/ --no-cache --push

# exec_there "$ROOT_DIR"/dist zip -r "$APP".zip "$APP" -x "*.DS_Store"

rm -rf "$ROOT_DIR"/dist