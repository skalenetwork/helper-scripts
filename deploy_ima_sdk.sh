#!/usr/bin/env bash
#
# This script can be used to deploy specified version of skale-manager and IMA to the provided endpoint
# with given private key
#

set -e

: "${ETH_PRIVATE_KEY?Need to set ETH_PRIVATE_KEY}"
: "${IMA_TAG?Need to set IMA_TAG}"
: "${ENDPOINT?Need to set ENDPOINT}"
: "${GAS_PRICE?Need to set GAS_PRICE}"

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export NETWORK=${NETWORK:-custom}

if [ ! -f $DIR/contracts_data/manager.json ]; then
    echo '{ "contract_manager_address": "0x0000000000000000000000000000000000000000" }' > $DIR/contracts_data/skaleManagerComponents.json
fi

source $DIR/helper.sh
deploy_ima_sdk $IMA_TAG $ENDPOINT $ETH_PRIVATE_KEY $GAS_PRICE
