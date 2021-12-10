#!/bin/bash -x

SOURCE_DIR="$(pwd)"
BUILD_LOCAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

app=$1
action=$2
env=$3

function set_linux_env() {

  export MOUNT_DIR="/mnt/$app"
  export BUILD_MOUNT_DIR="/mnt/build"
  export LOCAL_M2_DIR="${HOME}"/.m2
  export M2_DIR="${MOUNT_DIR}"/.m2
}

function set_osx_env() {

  export MOUNT_DIR="$SOURCE_DIR"
  export BUILD_MOUNT_DIR="$BUILD_LOCAL_DIR"/build
  export LOCAL_M2_DIR="${HOME}"/.m2
  export M2_DIR="${LOCAL_M2_DIR}"
}

function env_build() {

  mkdir -p "$BUILD_LOCAL_DIR"/buildx-cache

  docker buildx build  \
    --cache-from type=local,src="$BUILD_LOCAL_DIR"/buildx-cache,mode=max \
    --cache-to type=local,dest="$BUILD_LOCAL_DIR"/buildx-cache,mode=max \
    --platform linux/amd64 --build-arg ARCH=amd64 \
    -t adtsw/build:buster-amd64 "$BUILD_LOCAL_DIR"/build/env/buster --push
  docker buildx build  \
    --cache-from type=local,src="$BUILD_LOCAL_DIR"/buildx-cache,mode=max \
    --cache-to type=local,dest="$BUILD_LOCAL_DIR"/buildx-cache,mode=max \
    --platform linux/amd64 --build-arg ARCH=amd64 \
    -t adtsw/build:buster-graalvm-amd64 "$BUILD_LOCAL_DIR"/build/env/buster-graalvm --push
  docker buildx build  \
    --cache-from type=local,src="$BUILD_LOCAL_DIR"/buildx-cache,mode=max \
    --cache-to type=local,dest="$BUILD_LOCAL_DIR"/buildx-cache,mode=max \
    --platform linux/amd64 --build-arg ARCH=amd64 \
    -t adtsw/build:buster-node-amd64 "$BUILD_LOCAL_DIR"/build/env/buster-node --push
  
  docker buildx build \
    --cache-from type=local,src="$BUILD_LOCAL_DIR"/buildx-cache,mode=max \
    --cache-to type=local,dest="$BUILD_LOCAL_DIR"/buildx-cache,mode=max \
    --platform linux/arm64 --build-arg ARCH=aarch64 \
    -t adtsw/build:buster-aarch64 "$BUILD_LOCAL_DIR"/build/env/buster --push
  docker buildx build  \
    --cache-from type=local,src="$BUILD_LOCAL_DIR"/buildx-cache,mode=max \
    --cache-to type=local,dest="$BUILD_LOCAL_DIR"/buildx-cache,mode=max \
    --platform linux/arm64 --build-arg ARCH=aarch64 \
    -t adtsw/build:buster-graalvm-aarch64 "$BUILD_LOCAL_DIR"/build/env/buster-graalvm --push
#  docker buildx build  \
#    --cache-from type=local,src="$BUILD_LOCAL_DIR"/buildx-cache,mode=max \
#    --cache-to type=local,dest="$BUILD_LOCAL_DIR"/buildx-cache,mode=max \
#    --platform linux/arm64 --build-arg ARCH=aarch64 \
#    -t adtsw/build:buster-node "$BUILD_LOCAL_DIR"/build/env/buster-node --push
}

function clean() {
  
  set_osx_env
  "$BUILD_MOUNT_DIR"/scripts/clean.sh 
}

function jar_build_osx() {
  
  set_osx_env
  "$BUILD_MOUNT_DIR"/scripts/buildJar.sh "osx" 
}

function jar_build_linux() {

  set_linux_env
  docker run \
    -it \
    -m 4g \
    --cpus=2 \
    --cpuset-cpus 1-2 \
    -e MOUNT_DIR="${MOUNT_DIR}" \
    -e M2_DIR="${M2_DIR}" \
    -v "${SOURCE_DIR}":"${MOUNT_DIR}" \
    -v "${BUILD_LOCAL_DIR}"/build:"${BUILD_MOUNT_DIR}" \
    -v "${LOCAL_M2_DIR}":"${M2_DIR}" \
    adtsw/build:buster-graalvm \
    /bin/bash -c "$BUILD_MOUNT_DIR/scripts/buildJar.sh linux"
}

function jar_run_osx() {

  set_osx_env
  app="$1"
  module="$2"
  version="$3"
  vm_args="$4"
  main_class="$5"
  program_args="$6"
	"$BUILD_MOUNT_DIR"/scripts/runJar.sh "$app" osx "$module" "$version" "$vm_args" "$main_class" "$program_args" &
}

function jar_run_linux() {

	set_linux_env
  app="$1"
  module="$2"
  version="$3"
  vm_args="$4"
  main_class="$5"
  program_args="$6"
	CONTAINER_ID=$(docker run \
	  -d \
    -it \
    -m 4g \
    --cpus=4 \
    --cpuset-cpus 1-4 \
    -e MOUNT_DIR="${MOUNT_DIR}" \
    -e M2_DIR="${M2_DIR}" \
    -v "${SOURCE_DIR}":"${MOUNT_DIR}" \
    -v "${BUILD_LOCAL_DIR}"/build:"${BUILD_MOUNT_DIR}" \
    -v "${LOCAL_M2_DIR}":"${M2_DIR}" \
    -v /var/log:/var/log \
    -v /var/lib:/var/lib \
    -p 17400:17400 \
    -p 17402:17402 \
    -p 17403:17403 \
    -p 17410:17410 \
    adtsw/build:buster-graalvm \
    "$BUILD_MOUNT_DIR"/scripts/runJar.sh "$app" linux "$module" "$version" "$vm_args" "$main_class" "$program_args")
    echo "$CONTAINER_ID" > "/tmp/$module-linux-container-id"
}

function kill_jar_run_osx() {

  set_osx_env
  module="$1"
	"$BUILD_MOUNT_DIR"/scripts/killJar.sh "osx" "$module"
}

function kill_jar_run_linux() {

	set_linux_env
  module="$1"
	CONTAINER_ID=$(cat "/tmp/$module-linux-container-id")
  rm "/tmp/$module-linux-container-id"
	docker exec "$CONTAINER_ID" \
	  "$BUILD_MOUNT_DIR"/scripts/killJar.sh "linux" "$module"
}

function package() {

  set_osx_env
  app="$1"
  env="$2"
  module="$3"
  version="$4"
  packaged_jar_name="$5"
  repo_name="$6"
	"$BUILD_MOUNT_DIR"/scripts/package.sh "$app" "$env" "$module" "$version" "$packaged_jar_name" "$repo_name"
}

function test_run() {

  set_osx_env
  module="$1"
	"$BUILD_MOUNT_DIR"/scripts/"$module"Tests.sh
}

function native_build_osx() {

  set_osx_env
  module="$1"
  version="$2"
  main_class="$3"
  "$BUILD_MOUNT_DIR"/scripts/buildNative.sh "osx" "$module"
}

function native_build_linux() {

  set_linux_env
  module="$1"
  version="$2"
  main_class="$3"
  docker run \
    -it \
    -m 13g \
    --cpus=1 \
    -e MOUNT_DIR="${MOUNT_DIR}" \
    -e M2_DIR="${M2_DIR}" \
    -v "${LOCAL_DIR}":"${MOUNT_DIR}" \
    -v "${LOCAL_M2_DIR}":"${M2_DIR}" \
    adtsw/build:buster-graalvm "$BUILD_MOUNT_DIR"/scripts/buildNative.sh "linux" "$module"
}

function native_run() {

  set_linux_env
	docker run \
    -it \
    -m 13g \
    --cpus=1 \
    -e MOUNT_DIR="${MOUNT_DIR}" \
    -v "${LOCAL_DIR}":"${MOUNT_DIR}" \
    -p 17402:17402 \
    adtsw/build:buster "$BUILD_MOUNT_DIR"/scripts/runNative.sh "$module"
}

function publish_to_dropbox() {

  set_osx_env
  module="$1"
  refresh_token="$2"
  app_key="$3"
  app_secret="$4"
  "$BUILD_MOUNT_DIR"/scripts/publishToDropbox.sh "$module" "$refresh_token" "$app_key" "$app_secret"
}

function publish_to_docker() {

  set_osx_env
  repo_name="$1"
  "$BUILD_MOUNT_DIR"/scripts/publishToDocker.sh "$repo_name"
}

function launch_bash_on_base() {

  set_linux_env
  docker run \
    -it \
    -m 13g \
    --cpus=1 \
    -e MOUNT_DIR="${MOUNT_DIR}" \
    -e M2_DIR="${M2_DIR}" \
    -v "${LOCAL_DIR}":"${MOUNT_DIR}" \
    -v "${LOCAL_M2_DIR}":"${M2_DIR}" \
    -p 17400:17400 \
    -p 17402:17402 \
    -p 17403:17403 \
    adtsw/build:buster bash
}

function launch_bash_on_graalvm() {

  set_linux_env
  docker run \
    -it \
    -m 13g \
    --cpus=1 \
    -e MOUNT_DIR="${MOUNT_DIR}" \
    -e M2_DIR="${M2_DIR}" \
    -v "${LOCAL_DIR}":"${MOUNT_DIR}" \
    -v "${LOCAL_M2_DIR}":"${M2_DIR}" \
    -p 17400:17400 \
    -p 17402:17402 \
    -p 17403:17403 \
    adtsw/build:buster-graalvm bash
}

function launch_bash_on_node() {

  set_linux_env
  docker run \
    -it \
    -m 13g \
    --cpus=1 \
    -e MOUNT_DIR="${MOUNT_DIR}" \
    -e M2_DIR="${M2_DIR}" \
    -v "${LOCAL_DIR}":"${MOUNT_DIR}" \
    -v "${LOCAL_M2_DIR}":"${M2_DIR}" \
    -p 17400:17400 \
    -p 17402:17402 \
    -p 17403:17403 \
    adtsw/build:buster-node bash
}

function wait_for_service_start_osx() {
  
  set_osx_env
  module="$1"
  "$BUILD_MOUNT_DIR"/scripts/waitForServiceStart.sh "$module"
}

function wait_for_service_start_linux() {
  
  set_linux_env
  module="$1"
	docker exec "$CONTAINER_ID" \
	  "$BUILD_MOUNT_DIR"/scripts/waitForServiceStart.sh "$module"
}

function clean_native_config_files() {

  env="$1"
  module="$2"
  sed -i '' '/nashorn/d' "$LOCAL_DIR/native/configs/$module/$env/META-INF/native-image/resource-config.json"
  sed -i '' 's/{"name":"javax.servlet.http.LocalStrings"},/{"name":"javax.servlet.http.LocalStrings"}/g' \
    "$LOCAL_DIR/native/configs/$module/$env/META-INF/native-image/resource-config.json"
  gln=$(grep -n -m 1 graalvm \
    "$LOCAL_DIR/native/configs/$module/$env/META-INF/native-image/reflect-config.json" | \
    sed  's/\([0-9]*\).*/\1/')
  if [ -z "$gln" ]; 
  then 
    echo "not substituting graalvm reflection"; 
  else
    echo "substituting graalvm reflection"; 
    sed -i '' -e "$(expr $gln - 1),$(expr $gln + 2)d" \
      "$LOCAL_DIR/native/configs/$module/$env/META-INF/native-image/reflect-config.json" 
  fi
}

function clean_native_files() {

  env="$1"
  module="$2"
  rm -rf "$LOCAL_DIR/native/bin/$env/"*.*
}

function exec_there() {
  DIR="$1"
  shift
  (cd "$DIR" || exit; "$@")
}

case "$action" in
	build_env)
    env_build
		;;
	clean)
    clean
		;;
	build_jar)
	  case "$env" in
      osx)
        jar_build_osx
        ;;
      linux)
        jar_build_linux
        ;;
		esac
		;;
	run_jar)
    module=$4
    version="$5"
    vm_args=$6
    main_class=$7
    program_args=$8
    case "$env" in
      osx)
        jar_run_osx "$app" "$module" "$version" "$vm_args" "$main_class" "$program_args"
        ;;
      linux)
        jar_run_linux "$app" "$module" "$version" "$vm_args" "$main_class" "$program_args"
        ;;
		esac
		;;
	stop)
    module=$4
    case "$env" in
      osx)
        kill_jar_run_osx "$module"
        ;;
      linux)
        kill_jar_run_linux "$module"
        ;;
		esac
		;;
	package)
    module=$4
    version="$5"
    packaged_jar_name="$6"
    repo_name="$7"
    package "$app" "$env" "$module" "$version" "$packaged_jar_name" "$repo_name"
		;;
	run_tests)
    case "$env" in
      osx)
        jar_run_osx "$module"
        wait_for_service_start_osx "$module" 
        test_run "$module"
        sleep 2
        kill_jar_run_osx "$module"
        clean_native_config_files "$env" "$module"
        ;;
      linux)
        jar_run_linux "$module"
        wait_for_service_start_linux "$module"
        test_run "$module"
        sleep 2
        kill_jar_run_linux "$module"
        clean_native_config_files "$env" "$module"
        ;;
		esac
		;;
	build_native)
		case "$env" in
      osx)
        native_build_osx "$module"
        clean_native_files "$env" "$module"
        ;;
      linux)
        native_build_linux "$module"
        clean_native_files "$env" "$module"
        ;;
		esac
		;;
	run_native)
    native_run
    ;;
	publish_to_dropbox)
	  module=$4
    refresh_token="$5"
    app_key="$6"
    app_secret="$7"
    publish_to_dropbox "$module" "$refresh_token" "$app_key" "$app_secret"
		;;
	publish_to_docker)
	  repo_name=$4
    publish_to_docker "$repo_name"
		;;
	bash_base)
    launch_bash_on_base
    ;;
  bash_graalvm)
    launch_bash_on_graalvm
    ;;
  bash_node)
    launch_bash_on_node
    ;;
	*)
    echo "Usage: $0 {build_env|clean|build_jar|run_jar|run_tests|stop|package|run_tests|build_native|run_native|publish_to_dropbox|publish_to_docker|bash_build|bash_graalvm|bash_test}" >&2
    exit 1
    ;;
esac
