#!/usr/bin/env bash

CURRENT_SCRIPT="$(basename -- "${0:-}")"

# Read args passed to current script
ARGS=( "$@" )

function has_help_flag() {
    for i in "${ARGS[@]}"
    do
      [[ " $i " =~ " --help " ]] && return 0 || continue
    done
    return 1
}

function get_arg(){
    EXPECTED_ARG="${1:-}"
    FALLBACK_VALUE="${2:-}"

    VALUE=${FALLBACK_VALUE:-}

    for i in "${ARGS[@]}"
    do
        case "$i" in
            # --flag=value
            $EXPECTED_ARG=*)
                ARG="${i#*=}"
                VALUE=$ARG
                break
                ;;
            # --flag
            $EXPECTED_ARG)
                VALUE=1
                break
                ;;
            *)
        esac
    done

    [ -z "$VALUE" ] || echo "$CURRENT_SCRIPT: $EXPECTED_ARG=$VALUE"
    # If a value was found, or if a fallback was specified, output it
    [ -z "$VALUE" ] || echo $VALUE >&2
}