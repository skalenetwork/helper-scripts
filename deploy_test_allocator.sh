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
export NETWORK=${NETWORK:-custom}
export GAS_PRICE=${GAS_PRICE:-10000000000}
export ETHERSCAN=${ETHERSCAN:-1234}

source $DIR/helper.sh

export ALLOCATOR_NETWORK=${ALLOCATOR_NETWORK:-unique}

create_test_docker_network
run_ganache $ETH_PRIVATE_KEY
deploy_manager $MANAGER_TAG $DOCKER_NETWORK_ENDPOINT $ETH_PRIVATE_KEY $GAS_PRICE $NETWORK $ETHERSCAN
deploy_allocator $ALLOCATOR_TAG $DOCKER_NETWORK_ENDPOINT $ETH_PRIVATE_KEY $ALLOCATOR_PRODUCTION $GAS_PRICE $ALLOCATOR_NETWORK

MANAGER_ABI_FILE=$DIR/contracts_data/manager.json
ALLOCATOR_ABI_FILE=$DIR/allocator_contracts_data/allocator.json
RESULT_FILEPATH=$DIR/contracts_data/universal.json

create_universal_abi_file $MANAGER_ABI_FILE $ALLOCATOR_ABI_FILE $RESULT_FILEPATH
