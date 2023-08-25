#!/usr/bin/env bash
#
# This script can be used to deploy specified version of skale-manager and IMA to the provided endpoint
# with given private key
#

set -ea

: "${ETH_PRIVATE_KEY?Need to set ETH_PRIVATE_KEY}"
: "${MANAGER_TAG?Need to set MANAGER_TAG}"
: "${IMA_TAG?Need to set IMA_TAG}"

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export NETWORK=${NETWORK:-custom}
export GAS_PRICE=${GAS_PRICE:-10000000000}
export ETHERSCAN=${ETHERSCAN:-1234}

source $DIR/helper.sh

if [[ $CUSTOM_NETWORK ]]; then
    create_test_docker_network
    export DOCKER_NETWORK_ENDPOINT=http://ganache:8545
    export DOCKER_NETWORK=testnet
else
    export DOCKER_NETWORK_ENDPOINT=http://127.0.0.1:8545
    export DOCKER_NETWORK=host
fi


if [[ $GANACHE ]]; then
    run_ganache $ETH_PRIVATE_KEY
fi

deploy_manager $MANAGER_TAG $DOCKER_NETWORK_ENDPOINT $ETH_PRIVATE_KEY $GAS_PRICE $NETWORK $ETHERSCAN
echo "Copying $DIR/contracts_data/manager.json -> $DIR/contracts_data/skaleManagerComponents.json"
cp $DIR/contracts_data/manager.json $DIR/contracts_data/skaleManagerComponents.json
deploy_ima_proxy $IMA_TAG $DOCKER_NETWORK_ENDPOINT $ETH_PRIVATE_KEY $GAS_PRICE
