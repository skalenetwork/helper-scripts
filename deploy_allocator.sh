#!/usr/bin/env bash
#
# This script will deploy skale-allocator to the provided network endpoint
#

set -e

: "${ALLOCATOR_TAG?Need to set ALLOCATOR_TAG}"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DEPLOYMENT_ENDPOINT=${ENDPOINT:-'http://127.0.0.1:8545'}
GAS_PRICE=${GAS_PRICE:-10000000000}
NETWORK=${NETWORK:-custom}
DOCKER_NETWORK=${DOCKER_NETWORK:-host}

source "$DIR/helper.sh"

[[ $RUN_ANVIL ]] && run_anvil

PRIVATE_KEY=${ANVIL_PRIVATE_KEY:-$ETH_PRIVATE_KEY}
: "${PRIVATE_KEY?Need to set ETH_PRIVATE_KEY}"

ALLOCATOR_PRODUCTION=${ALLOCATOR_PRODUCTION:-true}

deploy_allocator $ALLOCATOR_TAG $DEPLOYMENT_ENDPOINT $PRIVATE_KEY $ALLOCATOR_PRODUCTION $GAS_PRICE
