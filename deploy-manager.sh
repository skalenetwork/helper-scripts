#!/usr/bin/env bash

set -e

: "${ETH_PRIVATE_KEY?Need to set ETH_PRIVATE_KEY}"
: "${MANAGER_TAG?Need to set MANAGER_TAG}"
: "${ENDPOINT?Need to set ENDPOINT}"

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker pull skalenetwork/skale-manager:$MANAGER_TAG
docker run \
    -v $DIR/contracts_data:/usr/src/manager/data \
    --network testnet \
    -e ENDPOINT=$ENDPOINT \
    -e PRIVATE_KEY=$ETH_PRIVATE_KEY \
    skalenetwork/skale-manager:$MANAGER_TAG \
    npx truffle migrate --network unique

cp $DIR/contracts_data/unique.json $DIR/abi.json