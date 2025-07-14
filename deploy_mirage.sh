#!/usr/bin/env bash
#
# This script can be used to deploy specified version of mirage-manager to the provided endpoint
# with given private key
#

set -e

: "${MIRAGE_TAG:?Need to set MIRAGE_TAG}"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DEPLOYMENT_ENDPOINT=${ENDPOINT:-'http://127.0.0.1:8545'}
GAS_PRICE=${GAS_PRICE:-10000000000}
ETHERSCAN=${ETHERSCAN:-1234}
NETWORK=${NETWORK:-custom}
DOCKER_NETWORK=${DOCKER_NETWORK:-host}

: "${CHAIN_NAME:?Need to set CHAIN_NAME}"
: "${TARGET:?Need to set TARGET}"
: "${MAINNET_ENDPOINT:?Need to set MAINNET_ENDPOINT}"

source "$DIR/helper.sh"

[[ $RUN_ANVIL ]] && run_anvil

PRIVATE_KEY=${ETH_PRIVATE_KEY:-$ANVIL_PRIVATE_KEY}
: "${PRIVATE_KEY:?Need to set ETH_PRIVATE_KEY}"

deploy_mirage "$MIRAGE_TAG" "$DEPLOYMENT_ENDPOINT" "$PRIVATE_KEY" "$GAS_PRICE" "$NETWORK" "$ETHERSCAN" "$CHAIN_NAME" "$TARGET" "$MAINNET_ENDPOINT"
