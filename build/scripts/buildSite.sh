#!/bin/bash -x

APP="$1"
ENV="$2"
MODULE="$3"

LOCAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "local dir : $LOCAL_DIR"
ROOT_DIR="$MOUNT_DIR"
echo "root dir : $ROOT_DIR"
echo "m2 dir : $M2_DIR"
echo "building for : $ENV"

function npm-there() {
  DIR="$1"
  shift
  (cd "$DIR" || exit; npm "$@")
}

rm -rf "$ROOT_DIR"/site/"$MODULE"/dist
rm -rf "$ROOT_DIR"/site/"$MODULE"/build

npm-there "$ROOT_DIR"/site/"$MODULE" run webpack-build