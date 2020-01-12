#!/usr/bin/env bash

set -euo pipefail
exec 3>&1

function on_error {
    echo "Something failed..."
    sleep 5
}
trap on_error ERR

REPO_ROOT="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="$REPO_ROOT/scripts"

source "$SCRIPT_DIR/get-arg.sh"
BUILD_DIR="$(get_arg --build-dir "$REPO_ROOT/build" 2>&1 >&3)"
if has_help_flag; then exit 0; else true; fi

DEP_PATH="$(cat $BUILD_DIR/conan-dependencies.txt)"
ACTIVATE_FILE="$DEP_PATH/activate.sh"

echo -e "\n-- Activating environment variables from conan package dependencies: \n--- $ACTIVATE_FILE"
if [ -e $ACTIVATE_FILE ]
then
    # Make available all environment variables from upstream conan packages
    old_setting=${-//[^u]/}
    set +u
    source $ACTIVATE_FILE
    if [[ -n "$old_setting" ]]; then set -u; fi
    echo -e "-- Environment variables now available.\n"
else
    echo -e "-- Could not find conan activation file. Did you forget to add 'virtualenv' generator in conanfile.txt?\n---- Expected file: $ACTIVATE_FILE\n"
fi