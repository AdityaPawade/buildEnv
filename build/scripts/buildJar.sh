#!/bin/bash -x

ENV="$1"

LOCAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "local dir : $LOCAL_DIR"
ROOT_DIR="$MOUNT_DIR"
echo "root dir : $ROOT_DIR"
echo "m2 dir : $M2_DIR"
echo "building for : $ENV"

function mvn-there() {
  DIR="$1"
  shift
  (cd "$DIR" || exit; mvn "$@")
}

mvn-there "$ROOT_DIR" -P"$ENV" clean compile install -DskipTests \
  -Dmaven.home=$M2_DIR -Dmaven.repo.local=$M2_DIR/repository