#!/bin/bash -x

APP="$1"
ENV="$2"
MODULE="$3"
VERSION="$4"
VM_ARGS="$5"
MAIN_CLASS="$6"
PROGRAM_ARGS="$7"

LOCAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "local dir : $LOCAL_DIR"
ROOT_DIR="$MOUNT_DIR"
echo "root dir : $ROOT_DIR"
JAR_FILE="$ROOT_DIR/$MODULE/target/$MODULE-$VERSION-$ENV.jar"
echo "jar file : $JAR_FILE"

USER=$(whoami)
sudo mkdir -p /var/lib/"$APP"
sudo mkdir -p /var/log/"$APP"
sudo chown "$USER" /var/lib/"$APP"
sudo chown "$USER" /var/log/"$APP"

cd "$ROOT_DIR" || exit

java $VM_ARGS -cp "$JAR_FILE" "$MAIN_CLASS" "$PROGRAM_ARGS" &
    
PROCESS_PID=$(echo $!)
echo "PID : $PROCESS_PID"
echo "$PROCESS_PID" > "/tmp/$MODULE-$ENV-pid"

while kill -0 "$PROCESS_PID" >/dev/null 2>&1
do
  sleep 1
done

echo "process killed"
