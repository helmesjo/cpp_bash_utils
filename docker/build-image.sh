#!/usr/bin/env bash

set -euo pipefail
exec 3>&1

function on_error {
    echo "Failed to build dockerfile '${DOCKERFILE:-}'..."
    sleep 5
    exit 1
}
trap on_error ERR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT=$(git rev-parse --show-toplevel)
SCRIPT_DIR="$REPO_ROOT/scripts"

source "$SCRIPT_DIR/get-arg.sh"
DOCKERFILE="$(get_arg --file "$DIR/images/linux-gcc.dockerfile" 2>&1 >&3)"
IMAGE_NAME="$(get_arg --tag "cpp_bash_utils:build" 2>&1 >&3)"
if has_help_flag; then exit 0; else true; fi

echo -e "\n-- Building docker image '$IMAGE_NAME' from file '$DOCKERFILE'...\n"

# Build environment
docker build    --tag $IMAGE_NAME \
                --file $DOCKERFILE . \
                2>&1 >&3

echo -e "\n-- Built docker image '$IMAGE_NAME' from file '$DOCKERFILE'.\n"

echo $IMAGE_NAME >&2

sleep 2