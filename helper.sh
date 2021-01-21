#!/usr/bin/env bash

set -e

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export DOCKER_NETWORK_ENDPOINT=http://ganache:8545

export SM_IMAGE_NAME="skale-manager"
export ALLOCATOR_IMAGE_NAME="skale-allocator"
export IMA_IMAGE_NAME="ima"
export SGX_WALLET_CONTAINER_NAME="sgx-simulator"

export DOCKER_NETWORK=${DOCKER_NETWORK:-testnet}
export GANACHE_VERSION=${GANACHE_VERSION:-beta}
export GANACHE_GAS_LIMIT=${GANACHE_GAS_LIMIT:-80000000}


run_manager () {
    : "${1?Pass MANAGER_TAG to ${FUNCNAME[0]}}"
    echo Going to run $SM_IMAGE_NAME:$1 docker container...

    mkdir -p $DIR/contracts_data/openzeppelin

    docker rm -f $SM_IMAGE_NAME || true
    docker pull skalenetwork/$SM_IMAGE_NAME:$1
    docker run \
        -ti \
        --name $SM_IMAGE_NAME \
        -v $DIR/contracts_data:/usr/src/manager/data \
        --mount type=volume,dst=/usr/src/manager/.openzeppelin,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=$DIR/contracts_data/openzeppelin \
        --network $DOCKER_NETWORK \
        skalenetwork/$SM_IMAGE_NAME:$1 \
        bash
}

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
#:param NETWORK: Network from the truffle-config.json file
#:type NETWORK: str
deploy_manager () {
    : "${1?Pass MANAGER_TAG to ${FUNCNAME[0]}}"
    : "${2?Pass ENDPOINT to ${FUNCNAME[0]}}"
    : "${3?Pass ETH_PRIVATE_KEY to ${FUNCNAME[0]}}"
    : "${4?Pass GAS_PRICE to ${FUNCNAME[0]}}"
    : "${5?Pass NETWORK to ${FUNCNAME[0]}}"
    echo Going to run $SM_IMAGE_NAME:$1 docker container...

    mkdir -p $DIR/contracts_data/openzeppelin

    docker rm -f $SM_IMAGE_NAME || true
    docker pull skalenetwork/$SM_IMAGE_NAME:$1
    docker run \
        --name $SM_IMAGE_NAME \
        -v $DIR/contracts_data:/usr/src/manager/data \
        --mount type=volume,dst=/usr/src/manager/.openzeppelin,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=$DIR/contracts_data/openzeppelin \
        --network $DOCKER_NETWORK \
        -e ENDPOINT=$2 \
        -e PRIVATE_KEY=$3 \
        -e GASPRICE=$4 \
        skalenetwork/$SM_IMAGE_NAME:$1 \
        npx truffle migrate --network $5

    echo Copying $DIR/contracts_data/$NETWORK.json -> $DIR/contracts_data/manager.json
    cp $DIR/contracts_data/$NETWORK.json $DIR/contracts_data/manager.json
    docker rm -f $SM_IMAGE_NAME || true
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
    : "${5?Pass GAS_PRICE to ${FUNCNAME[0]}}"
    : "${6?Pass NETWORK to ${FUNCNAME[0]}}"

    SM_ABI_FILEPATH=$DIR/contracts_data/manager.json
    if [ ! -f $SM_ABI_FILEPATH ]; then
        echo "$SM_ABI_FILEPATH file not found!"
        exit 3
    fi

    echo Going to run $ALLOCATOR_IMAGE_NAME:$1 docker container...

    docker rm -f $ALLOCATOR_IMAGE_NAME || true

     mkdir -p $DIR/allocator_contracts_data/openzeppelin

    docker pull skalenetwork/$ALLOCATOR_IMAGE_NAME:$1
    docker run \
        -d \
        --name $ALLOCATOR_IMAGE_NAME \
        -v $DIR/contracts_data:/usr/src/manager_data \
        -v $DIR/allocator_contracts_data:/usr/src/allocator/data \
        --mount type=volume,dst=/usr/src/allocator/.openzeppelin,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=$DIR/allocator_contracts_data/openzeppelin \
        --network $DOCKER_NETWORK \
        -e ENDPOINT=$2 \
        -e PRIVATE_KEY=$3 \
        -e PRODUCTION=$4 \
        -e GASPRICE=$5 \
        skalenetwork/$ALLOCATOR_IMAGE_NAME:$1 \
        bash /bootstrap.sh

    MIGRATE_CMD="npx truffle migrate --network $6"

    docker exec $ALLOCATOR_IMAGE_NAME bash -c "cp /usr/src/manager_data/manager.json /usr/src/allocator/scripts/manager.json"
    docker exec $ALLOCATOR_IMAGE_NAME bash -c "$MIGRATE_CMD"

    echo Copying $DIR/allocator_contracts_data/$NETWORK.json to $DIR/allocator_contracts_data/manager.json
    cp $DIR/allocator_contracts_data/$NETWORK.json $DIR/allocator_contracts_data/allocator.json

    docker rm -f $ALLOCATOR_IMAGE_NAME || true
}



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
deploy_ima_proxy () {
    : "${1?Pass IMA_TAG to ${FUNCNAME[0]}}"
    : "${2?Pass ENDPOINT to ${FUNCNAME[0]}}"
    : "${3?Pass ETH_PRIVATE_KEY to ${FUNCNAME[0]}}"
    : "${4?Pass GAS_PRICE to ${FUNCNAME[0]}}"
    echo Going to run $IMA_IMAGE_NAME:$1 docker container...

    mkdir -p $DIR/contracts_data/openzeppelin

    docker rm -f $IMA_IMAGE_NAME || true
    docker pull skalenetwork/$IMA_IMAGE_NAME:$1
    docker run \
        --name $IMA_IMAGE_NAME \
        -v $DIR/contracts_data:/usr/src/proxy/data \
        --mount type=volume,dst=/usr/src/proxy/.openzeppelin,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=$DIR/contracts_data/openzeppelin \
        --network $DOCKER_NETWORK \
        -e URL_W3_ETHEREUM=$2 \
        -e PRIVATE_KEY_FOR_ETHEREUM=$3 \
        -e GASPRICE=$4 \
        -e NETWORK="mainnet" \
        skalenetwork/$IMA_IMAGE_NAME:$1 \
        npx truffle migrate --network $5

    echo Copying $DIR/contracts_data/proxyMainnet.json -> $DIR/contracts_data/ima.json
    cp $DIR/contracts_data/proxyMainnet.json $DIR/contracts_data/ima.json
    docker rm -f $IMA_IMAGE_NAME || true
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


create_test_docker_network () {
    docker network create $DOCKER_NETWORK || true
}


create_universal_abi_file () {
    : "${1?Pass MANAGER_FILEPATH to ${FUNCNAME[0]}}"
    : "${2?Pass ALLOCATOR_FILEPATH to ${FUNCNAME[0]}}"
    : "${3?Pass RESULT_FILEPATH to ${FUNCNAME[0]}}"
    python $DIR/create_universal_abi_file.py $1 $2 $3
}
