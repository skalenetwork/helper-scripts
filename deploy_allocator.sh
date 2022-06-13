#!/usr/bin/env bash
#
# This script will deploy skale-allocator to the provided network endpoint
#

set -e

: "${ETH_PRIVATE_KEY?Need to set ETH_PRIVATE_KEY}"
: "${ALLOCATOR_TAG?Need to set ALLOCATOR_TAG}"
: "${ENDPOINT?Need to set ENDPOINT}"
: "${GAS_PRICE?Need to set GAS_PRICE}"

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export ALLOCATOR_PRODUCTION=${ALLOCATOR_PRODUCTION:-true}

source $DIR/helper.sh
deploy_allocator $ALLOCATOR_TAG $ENDPOINT $ETH_PRIVATE_KEY $ALLOCATOR_PRODUCTION $GAS_PRICE
