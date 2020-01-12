#!/usr/bin/env bash

set -euo pipefail
exec 3>&1

# Clean up leftovers before exit
function cleanup {
    if [ "${CONTAINER_ID-}" ]; then
        docker rm $CONTAINER_ID
    fi
}
trap cleanup EXIT

function on_error {
    echo "Failed to run command '$COMMAND' inside container..."
    cleanup
    sleep 3
    exit 1
}
trap on_error ERR

# Check that argument was specified
if [[ $# -eq 0 ]] ; then
    echo "No arguments specified"
    exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="$REPO_ROOT/scripts"

source "$SCRIPT_DIR/get-arg.sh"
COMMAND="$(get_arg --command "ls" 2>&1 >&3)"
DOCKERFILE="$(get_arg --dockerfile "$DIR/images/linux-gcc.dockerfile" 2>&1 >&3)"
IMAGE_TAG="$(get_arg --image-tag "cpp_bash_utils:build" 2>&1 >&3)"
NETWORK="$(get_arg --network "bridge" 2>&1 >&3)"
if has_help_flag; then exit 0; else true; fi

# Make sure image is built
IMAGE_ID=$($DIR/build-image.sh --file=$DOCKERFILE --tag=$IMAGE_TAG 2>&1 >&3)

echo -e "\n-- Running command '$COMMAND' inside container (Image: '$IMAGE_TAG' File: '$DOCKERFILE')...\n"

# Create build container & compile (create+start instead of run because of issues with logs)

CONTAINER_WDIR=//source
CONTAINER_ID=$( docker create \
                        --tty \
                        --attach STDIN \
                        --attach STDOUT \
                        --attach STDERR \
                        --net $NETWORK \
                        --volume /$REPO_ROOT:$CONTAINER_WDIR \
                        --workdir $CONTAINER_WDIR \
                        $IMAGE_ID \
                        sh -c "$COMMAND" \
                )

docker start --attach $CONTAINER_ID

echo -e "\n-- DONE running command '$COMMAND' inside container (Image: '$IMAGE_TAG' File: '$DOCKERFILE')...\n"

sleep 3