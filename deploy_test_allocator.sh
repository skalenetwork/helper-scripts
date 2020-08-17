#!/usr/bin/env bash
#
# This script will create a new instance of ganache and deploy skale-manager to it
#

set -e

: "${ETH_PRIVATE_KEY?Need to set ETH_PRIVATE_KEY}"
: "${MANAGER_TAG?Need to set MANAGER_TAG}"
: "${ALLOCATOR_TAG?Need to set ALLOCATOR_TAG}"

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export DOCKER_NETWORK_ENDPOINT=http://ganache:8545
export ALLOCATOR_PRODUCTION=${ALLOCATOR_PRODUCTION:-true}

source $DIR/helper.sh

run_ganache $ETH_PRIVATE_KEY
deploy_manager $MANAGER_TAG $DOCKER_NETWORK_ENDPOINT $ETH_PRIVATE_KEY
deploy_allocator $ALLOCATOR_TAG $DOCKER_NETWORK_ENDPOINT $ETH_PRIVATE_KEY $ALLOCATOR_PRODUCTION
