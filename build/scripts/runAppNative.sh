#!/bin/bash

PROGRAM_ARGS="$1"
MODULE="$2"

LOCAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "local dir : $LOCAL_DIR"
ROOT_DIR="$MOUNT_DIR"
echo "root dir : $ROOT_DIR"
BINARY="$ROOT_DIR"/dist/server/bin/"$MODULE"
echo "binary dir : $BINARY"
CONFIG_DIR="$ROOT_DIR"/configurations/prod
echo "config dir : $CONFIG_DIR"
echo "program args : $PROGRAM_ARGS"

$BINARY -Dconfig=$CONFIG_DIR -Dlog4j.configurationFile=file-log4j2.xml $PROGRAM_ARGS
