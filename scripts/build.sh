#!/usr/bin/env bash

# Read here: https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
set -euo pipefail
exec 3>&1

function on_error {
    echo "Something failed..."
    sleep 5
    exit 1
}
trap on_error ERR

REPO_ROOT="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="$REPO_ROOT/scripts"

source "$SCRIPT_DIR/get-arg.sh"
GENERATE="$(get_arg --generate 2>&1 >&3)"
TARGET="$(get_arg --target "all" 2>&1 >&3)"
BUILD_DIR="$(get_arg --build-dir "$REPO_ROOT/build" 2>&1 >&3)"
CONFIG="$(get_arg --config "Release" 2>&1 >&3)"
TARGET_OS="$(get_arg --target-os "$($SCRIPT_DIR/get-os.sh 2>&1 >&3)" 2>&1 >&3)"
TARGET_ARCH="$(get_arg --target-arch "$($SCRIPT_DIR/get-arch.sh 2>&1 >&3)" 2>&1 >&3)"
BUILD_SHARED="$(get_arg --shared 2>&1 >&3)"
INSTALL_DIR="$(get_arg --install-dir "./output" 2>&1 >&3)"
COMPILER="$(get_arg --compiler "$($SCRIPT_DIR/get-compiler.sh --target-os=$TARGET_OS 2>&1 >&3)" 2>&1 >&3)"
if has_help_flag; then exit 0; else true; fi

TOOLCHAIN=$($REPO_ROOT/cmake/determine-toolchain.sh  --compiler=$COMPILER --target-os=$TARGET_OS --target-arch=$TARGET_ARCH 2>&1 >/dev/null)

# Make all environment variables from upstream conan packages available to current session
source "$REPO_ROOT/conan/activate-envars.sh" --build-dir=$BUILD_DIR

BUILD_TYPE=`if [ -z "${BUILD_SHARED-}" ] || [ "${BUILD_SHARED,,}" == "false" ]; then echo "Static"; else echo "Shared"; fi`

echo -e "\n-- Building for '$TARGET_OS-$TARGET_ARCH-$CONFIG-$BUILD_TYPE' with toolchain '$TOOLCHAIN'..."

cmake -E make_directory $BUILD_DIR

# Generate
if [ "${GENERATE}" != "" ]; then
    cmake -E chdir $BUILD_DIR \
        cmake ..    -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=TRUE \
                    -DCMAKE_BUILD_TYPE=$CONFIG \
                    -DBUILD_SHARED_LIBS=$BUILD_SHARED \
                    -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN \
                    -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR
fi

# Build
cmake -E chdir $BUILD_DIR \
    cmake --build . --target $TARGET --config $CONFIG

echo -e "\n-- Finished building for '$TARGET_OS-$TARGET_ARCH-$CONFIG-$BUILD_TYPE' with toolchain '$TOOLCHAIN'."

sleep 3