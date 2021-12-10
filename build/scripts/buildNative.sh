#!/bin/bash -x

ENV="$1"
MODULE="$2"
VERSION="$3"
MAIN_CLASS="$4"

LOCAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "local dir : $LOCAL_DIR"
ROOT_DIR="$MOUNT_DIR"
echo "root dir : $ROOT_DIR"
META_DIR="$ROOT_DIR"/native/configs/"$MODULE"/"$ENV"
echo "meta dir : $META_DIR"
#TARGET="$ROOT_DIR"/dist/server/bin/"$ENV"/"$MODULE"
TARGET="$ROOT_DIR"/native/bin/"$ENV"/"$MODULE"
echo "target dir : $TARGET"
JAR_FILE="$ROOT_DIR"/target/"$MODULE"-"$VERSION"-"$ENV".jar
echo "jar dir : $JAR_FILE"

STATIC_FLAGS=""
if [ "$ENV" = "linux" ]; 
then 
  STATIC_FLAGS="--static --libc=musl"; 
else
  STATIC_FLAGS=""; 
fi
echo "static flags : $STATIC_FLAGS"

#  -J-Xmx2G \

native-image \
  -Dorg.bytedeco.javacpp.logger=slf4j \
  -H:-DeadlockWatchdogExitOnTimeout \
  --no-server \
  $STATIC_FLAGS \
	-cp "$META_DIR":"$JAR_FILE" "$MAIN_CLASS" \
	-H:Name="$TARGET" \
	-H:EnableURLProtocols=http,https \
	-H:+ReportExceptionStackTraces \
	--initialize-at-build-time=org.eclipse.jetty,javax.servlet,org.slf4j,org.apache.logging,ch.qos.logback \
	--no-fallback \
	--allow-incomplete-classpath \
	--features=org.graalvm.home.HomeFinderFeature \
	--report-unsupported-elements-at-runtime \
	--enable-all-security-services \
  -H:+AddAllCharsets \
  --install-exit-handlers \
  | grep -v ClassNotFoundException
	
upx -9 "$TARGET"