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
    echo "$DIR/contracts_data/manager.json not found, could not deploy IMA!"
    exit 1
fi

source $DIR/helper.sh
echo "Copying $DIR/contracts_data/manager.json -> $DIR/contracts_data/skaleManagerComponents.json"
cp $DIR/contracts_data/manager.json $DIR/contracts_data/skaleManagerComponents.json
deploy_ima_proxy $IMA_TAG $ENDPOINT $ETH_PRIVATE_KEY $GAS_PRICE
