#!/usr/bin/env bash
set -euo pipefail
exec 3>&1

function on_error {
    echo "Failed to find a C++ compiler..."
    sleep 3
    exit 1
}
trap on_error ERR

REPO_ROOT=$(git rev-parse --show-toplevel)
SCRIPT_DIR="$REPO_ROOT/scripts"

source "$SCRIPT_DIR/get-arg.sh"
TARGET_OS="$(get_arg --target-os "$($SCRIPT_DIR/get-os.sh 2>&1 >&3)" 2>&1 >&3)"
HOST_OS="$(get_arg --host-os "$($SCRIPT_DIR/get-os.sh 2>&1 >&3)" 2>&1 >&3)"
if has_help_flag; then exit 0; else true; fi

COMPILER="compiler_not_found"

if [ $TARGET_OS = "windows" ]; then
    if [ $HOST_OS == "linux" ]; then
        COMPILER="mingw"
    else
        COMPILER="msvc"
    fi
elif command -v clang >/dev/null; then
    COMPILER="clang"
elif command -v gcc >/dev/null; then
    COMPILER="gcc"
fi

echo "$COMPILER" >&2