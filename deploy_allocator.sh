#!/usr/bin/env bash
#
# This script will deploy skale-manager and skale-allocator to the provided network endpoint
#

set -e

: "${ETH_PRIVATE_KEY?Need to set ETH_PRIVATE_KEY}"
: "${MANAGER_TAG?Need to set MANAGER_TAG}"
: "${ALLOCATOR_TAG?Need to set ALLOCATOR_TAG}"
: "${ENDPOINT?Need to set ENDPOINT}"

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export ALLOCATOR_PRODUCTION=${ALLOCATOR_PRODUCTION:-true}

source $DIR/helper.sh

deploy_manager $MANAGER_TAG $ENDPOINT $ETH_PRIVATE_KEY
deploy_allocator $ALLOCATOR_TAG $ENDPOINT $ETH_PRIVATE_KEY $ALLOCATOR_PRODUCTION
