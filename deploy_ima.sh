#!/usr/bin/env bash
#
# This script can be used to deploy specified version of skale-manager and IMA to the provided endpoint
# with given private key
#

set -e

: "${IMA_TAG?Need to set IMA_TAG}"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DEPLOYMENT_ENDPOINT=${ENDPOINT:-'http://127.0.0.1:8545'}
GAS_PRICE=${GAS_PRICE:-10000000000}
ETHERSCAN=${ETHERSCAN:-1234}
NETWORK=${NETWORK:-custom}
DOCKER_NETWORK=${DOCKER_NETWORK:-host}

source "$DIR/helper.sh"

[[ $RUN_ANVIL ]] && run_anvil

PRIVATE_KEY=${ETH_PRIVATE_KEY:-$ANVIL_PRIVATE_KEY}
: "${PRIVATE_KEY?Need to set ETH_PRIVATE_KEY}"

MANAGER_JSON="$DIR/contracts_data/manager.json"
if [[ ! -f $MANAGER_JSON ]]; then
    echo "$MANAGER_JSON not found, could not deploy IMA!"
    exit 1
fi

echo "Copying $MANAGER_JSON -> $DIR/contracts_data/skaleManagerComponents.json"
cp "$MANAGER_JSON" "$DIR/contracts_data/skaleManagerComponents.json"

SKALE_MANAGER_ADDRESS=$(jq -r '.skale_manager_address' "$MANAGER_JSON")
deploy_ima_proxy "$IMA_TAG" "$DEPLOYMENT_ENDPOINT" "$PRIVATE_KEY" "$GAS_PRICE" "$SKALE_MANAGER_ADDRESS"
