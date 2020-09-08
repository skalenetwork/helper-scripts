#!/usr/bin/env bash

set -e

: "${MANAGER_TAG?Need to set MANAGER_TAG}"

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $DIR/helper.sh

create_test_docker_network
run_manager $MANAGER_TAG
