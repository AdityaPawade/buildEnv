#!/bin/bash

ENV="$1"
MODULE="$2"

LOCAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "local dir : $LOCAL_DIR"
ROOT_DIR="$MOUNT_DIR"
echo "root dir : $ROOT_DIR"

PROCESS_PID=$(cat "/tmp/$MODULE-$ENV-pid")
rm "/tmp/$MODULE-$ENV-pid"
kill "$PROCESS_PID"

while kill -0 "$PROCESS_PID" >/dev/null 2>&1
do
  sleep 1
done
