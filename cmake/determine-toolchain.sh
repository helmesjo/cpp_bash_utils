#!/usr/bin/env bash
set -euo pipefail
exec 3>&1

function on_error {
    echo "Failed to determine cmake toolchain..."
    sleep 3
    exit 1
}
trap on_error ERR

REPO_ROOT=$(git rev-parse --show-toplevel)
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOOLCHAIN_DIR="$CURRENT_DIR/toolchain"

SCRIPT_DIR="$REPO_ROOT/scripts"

source "$SCRIPT_DIR/get-arg.sh"
TARGET_OS="$(get_arg --target-os "$($SCRIPT_DIR/get-os.sh 2>&1 >&3)" 2>&1 >&3)"
TARGET_ARCH="$(get_arg --target-arch "$($SCRIPT_DIR/get-arch.sh 2>&1 >&3)" 2>&1 >&3)"
COMPILER="$(get_arg --compiler "$($SCRIPT_DIR/get-compiler.sh --target-os=$TARGET_OS 2>&1 >&3)" 2>&1 >&3)"
if has_help_flag; then exit 0; else true; fi

TOOLCHAIN="$TOOLCHAIN_DIR/$TARGET_OS-$COMPILER-$TARGET_ARCH.cmake"

# If toolchain doesn't exist
if [ ! -f "$TOOLCHAIN" ]; then
    "No toolchain found matching '$TOOLCHAIN'"
    on_error
fi

echo "$TOOLCHAIN" >&2