#!/usr/bin/env bash
#
# This script can be used to deploy specified version of mirage-manager to the provided endpoint
# with given private key
#

set -ea

: "${ETH_PRIVATE_KEY?Need to set ETH_PRIVATE_KEY}"
: "${MIRAGE_TAG?Need to set MIRAGE_TAG}"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DEPLOYMENT_ENDPOINT='http://127.0.0.1:8545'
NETWORK=${NETWORK:-custom}
GAS_PRICE=${GAS_PRICE:-10000000000}
ETHERSCAN=${ETHERSCAN:-1234}
DOCKER_NETWORK='host'

source $DIR/helper.sh

if [[ $ENDPOINT ]]; then
    DEPLOYMENT_ENDPOINT=$ENDPOINT
fi

if [[ $GANACHE ]]; then
    run_ganache $ETH_PRIVATE_KEY
fi

sleep 5

deploy_mirage $MIRAGE_TAG $DEPLOYMENT_ENDPOINT $ETH_PRIVATE_KEY $GAS_PRICE $NETWORK $ETHERSCAN
