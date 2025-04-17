#!/usr/bin/env bash
#
# This script can be used to deploy specified version of mirage-manager to the provided endpoint
# with given private key
#

set -ea

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

if [[ $RUN_ANVIL ]]; then
    run_anvil
fi

PRIVATE_KEY=$ETH_PRIVATE_KEY
if [[ $ANVIL_PRIVATE_KEY ]]; then
    echo "Using anvil private key"
    PRIVATE_KEY=$ANVIL_PRIVATE_KEY
fi

: "${PRIVATE_KEY?Need to set PRIVATE_KEY}"

deploy_mirage $MIRAGE_TAG $DEPLOYMENT_ENDPOINT $PRIVATE_KEY $GAS_PRICE $NETWORK $ETHERSCAN
