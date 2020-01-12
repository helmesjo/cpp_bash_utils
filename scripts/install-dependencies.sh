#!/usr/bin/env bash
set -euo pipefail
exec 3>&1

function on_error {
    echo -e "\n-- Dependencies NOT installed.\n"
    sleep 3
    exit 1
}
trap on_error ERR

command -v conan >/dev/null 2>&1 || 
{ 
    echo -e "-- CONAN PACKAGE MANAGER is used to install dependencies\n - Please install with 'pip install conan'"
    on_error
}

REPO_ROOT=$(git rev-parse --show-toplevel)
SCRIPT_DIR="$REPO_ROOT/scripts"

source "$SCRIPT_DIR/get-arg.sh"
LOCAL_CACHE="$(get_arg --local-cache 2>&1 >&3)"
BUILD_DIR="$(get_arg --build-dir "$REPO_ROOT/build" 2>&1 >&3)"
CONFIG="$(get_arg --config "Release" 2>&1 >&3)"
TARGET_OS="$(get_arg --target-os "$($SCRIPT_DIR/get-os.sh 2>&1 >&3)" 2>&1 >&3)"
TARGET_ARCH="$(get_arg --target-arch "$($SCRIPT_DIR/get-arch.sh 2>&1 >&3)" 2>&1 >&3)"
HOST_OS="$(get_arg --host-os "$($SCRIPT_DIR/get-os.sh 2>&1 >&3)" 2>&1 >&3)"
HOST_ARCH="$(get_arg --host-arch "$($SCRIPT_DIR/get-arch.sh 2>&1 >&3)" 2>&1 >&3)"
COMPILER="$(get_arg --compiler "$($SCRIPT_DIR/get-compiler.sh --target-os=$TARGET_OS 2>&1 >&3)" 2>&1 >&3)"
if has_help_flag; then exit 0; else true; fi

PROFILE="$($REPO_ROOT/conan/determine-profile.sh --compiler=$COMPILER --target-os=$TARGET_OS 2>&1 >&3)"

echo -e "\n-- Installing dependencies for '$TARGET_OS-$TARGET_ARCH-$CONFIG' with profile '$PROFILE'..."

conan --version

# # Make build-dir path absolute
case $BUILD_DIR in
  /*) ;& # Absolute on most OS
  *:*) ;; # Absolute on Windows
  *) BUILD_DIR="$REPO_ROOT/$BUILD_DIR" ;;
esac

if [ ${LOCAL_CACHE} ]; then
    # Use a local cache for dependencies
    echo -e "\n-- Using local cache for conan dependencies: '$BUILD_DIR'"
    export CONAN_USER_HOME="$BUILD_DIR"
fi

# Add bincrafters remote
conan remote add --insert 0 bincrafters https://api.bintray.com/conan/bincrafters/public-conan >/dev/null 2>&1 || true
# Add personal remote
conan remote add --insert 0 helmesjo https://api.bintray.com/conan/helmesjo/public-conan >/dev/null 2>&1 || true

# Conan output dir
DEPENDENCIES_DIR="$BUILD_DIR/dependencies/$CONFIG/$TARGET_ARCH"
cmake -E make_directory "$DEPENDENCIES_DIR"

# This is the file the root CMakeLists.txt will include. It tells cmake where to look for 'Find'-scripts (AKA where to find dependencies)
cmake -E echo "$DEPENDENCIES_DIR" > "$BUILD_DIR/conan-dependencies.txt"

# Generate default profile. It is inherited inside profiles to autofill settings
conan profile new default --detect >/dev/null 2>&1 || true

# Install dependencies. Build if pre-built is missing.
cmake -E chdir "$DEPENDENCIES_DIR" \
    conan install "$REPO_ROOT" --build=missing \
        -s arch=$TARGET_ARCH \
        -s build_type=$CONFIG \
        -s arch_build=$HOST_ARCH \
        -s os_build="${HOST_OS^}" \
        --profile=$PROFILE

echo -e "\n-- Installed dependencies for '$TARGET_OS-$TARGET_ARCH-$CONFIG' with profile '$PROFILE'.\n"
sleep 2