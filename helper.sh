#!/usr/bin/env bash

set -e

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export DOCKER_NETWORK_ENDPOINT=http://ganache:8545

export SM_IMAGE_NAME="skale-manager"
export ALLOCATOR_IMAGE_NAME="skale-allocator"
export SGX_WALLET_CONTAINER_NAME="sgx-simulator"

export DOCKER_NETWORK=${DOCKER_NETWORK:-testnet}
export GANACHE_VERSION=${GANACHE_VERSION:-beta}
export GANACHE_GAS_LIMIT=${GANACHE_GAS_LIMIT:-80000000}


# Deploy SKALE Manager to the specified RPC endpoint
#
# Results will saved in {CURRENT_DIR}/contracts_data/{NETWORK_NAME}.json
#
#:param MANAGER_TAG: Tag of the SKALE Manager Docker container
#:type MANAGER_TAG: str
#:param ENDPOINT: Ethereum RPC endpoint
#:type ENDPOINT: str
#:param ETH_PRIVATE_KEY: Ethereum private key (WITHOUT 0x prefix)
#:type ETH_PRIVATE_KEY: str
deploy_manager () {
    : "${1?Pass MANAGER_TAG to ${FUNCNAME[0]}}"
    : "${2?Pass ENDPOINT to ${FUNCNAME[0]}}"
    : "${3?Pass ETH_PRIVATE_KEY to ${FUNCNAME[0]}}"
    echo Going to run $SM_IMAGE_NAME:$1 docker container...

    docker rm -f $SM_IMAGE_NAME || true
    docker pull skalenetwork/$SM_IMAGE_NAME:$1
    docker run \
        --name $SM_IMAGE_NAME \
        -v $DIR/contracts_data:/usr/src/manager/data \
        --network $DOCKER_NETWORK \
        -e ENDPOINT=$2 \
        -e PRIVATE_KEY=$3 \
        skalenetwork/$SM_IMAGE_NAME:$1 \
        npx truffle migrate --network unique
}


# Deploy SKALE Allocator to the specified RPC endpoint
#
# Results will saved in {CURRENT_DIR}/allocator_contracts_data/{NETWORK_NAME}.json
#
#:param ALLOCATOR_TAG: Tag of the SKALE Allocator Docker container
#:type ALLOCATOR_TAG: str
#:param ENDPOINT: Ethereum RPC endpoint
#:type ENDPOINT: str
#:param ETH_PRIVATE_KEY: Ethereum private key (WITHOUT 0x prefix)
#:type ETH_PRIVATE_KEY: str
#:param ALLOCATOR_PRODUCTION: Production or develop contracts
#:type ALLOCATOR_PRODUCTION: bool
deploy_allocator () {
    : "${1?Pass ALLOCATOR_TAG to ${FUNCNAME[0]}}"
    : "${2?Pass ENDPOINT to ${FUNCNAME[0]}}"
    : "${3?Pass ETH_PRIVATE_KEY to ${FUNCNAME[0]}}"
    : "${4?Pass ALLOCATOR_PRODUCTION to ${FUNCNAME[0]}}"
    echo Going to run $ALLOCATOR_IMAGE_NAME:$1 docker container...

    docker rm -f $ALLOCATOR_IMAGE_NAME || true

    docker pull skalenetwork/$ALLOCATOR_IMAGE_NAME:$1
    docker run \
        -d \
        --name $ALLOCATOR_IMAGE_NAME \
        -v $DIR/contracts_data:/usr/src/manager_data \
        -v $DIR/allocator_contracts_data:/usr/src/allocator/data \
        --network $DOCKER_NETWORK \
        -e ENDPOINT=$2 \
        -e PRIVATE_KEY=$3 \
        -e PRODUCTION=$4 \
        skalenetwork/$ALLOCATOR_IMAGE_NAME:$1 \
        bash /bootstrap.sh

    docker exec $ALLOCATOR_IMAGE_NAME bash -c "cp /usr/src/manager_data/unique.json /usr/src/allocator/scripts/manager.json"
    docker exec $ALLOCATOR_IMAGE_NAME bash -c "npx truffle migrate --network unique"
    docker rm -f $ALLOCATOR_IMAGE_NAME || true
}


# Run ganache container with given private key
#
# Previous ganache container will be removed
#
#:param ETH_PRIVATE_KEY: Ethereum private key (WITHOUT 0x prefix)
#:type ETH_PRIVATE_KEY: str
run_ganache () {
    : "${1?Pass ETH_PRIVATE_KEY to ${FUNCNAME[0]}}"
    echo Going to run ganache docker container...

    docker rm -f ganache || true
    docker run -d --network $DOCKER_NETWORK -p 8545:8545 -p 8546:8546 \
        --name ganache trufflesuite/ganache-cli:$GANACHE_VERSION \
        --account="0x${1},100000000000000000000000000" -l 80000000 -b 1
}


# Run docker container with sgx simulator
#
# Previous sgx-simulator container will be removed
#
#:param SGX_WALLET_TAG: Tag of the SGX simulator Docker container
#:type SGX_WALLET_TAG: str
run_sgx_simulator () {
    : "${1?Pass SGX_WALLET_TAG to ${FUNCNAME[0]}}"
    SGX_WALLET_IMAGE_NAME=skalenetwork/sgxwallet_sim:$1

    docker rm -f $SGX_WALLET_CONTAINER_NAME || true
    docker pull $SGX_WALLET_IMAGE_NAME
    docker run -d -p 1026-1028:1026-1028 --name $SGX_WALLET_CONTAINER_NAME $SGX_WALLET_IMAGE_NAME -s -y -a
}
