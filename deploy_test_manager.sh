#!/usr/bin/env bash
#
# This script can be used to deploy specified version of skale-manager to the provided endpoint
# with given private key
#

set -e

export $(egrep -v '^#' .env | xargs)

: "${ETH_PRIVATE_KEY?Need to set ETH_PRIVATE_KEY}"
: "${MANAGER_TAG?Need to set MANAGER_TAG}"

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export DOCKER_NETWORK_ENDPOINT=http://ganache:8545

source $DIR/helper.sh

create_test_docker_network
run_ganache $ETH_PRIVATE_KEY
deploy_manager $MANAGER_TAG $DOCKER_NETWORK_ENDPOINT $ETH_PRIVATE_KEY
