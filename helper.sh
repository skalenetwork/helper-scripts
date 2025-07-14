#!/usr/bin/env bash

set -e

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export DOCKER_NETWORK_ENDPOINT=http://ganache:8545

export SM_IMAGE_NAME="skale-manager"
export ALLOCATOR_IMAGE_NAME="skale-allocator"
export IMA_IMAGE_NAME="ima-contracts"
export MIRAGE_IMAGE_NAME="professional"
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
#:param NETWORK: Network from the truffle-config.json file - not used
#:type NETWORK: str
deploy_manager () {
    : "${1?Pass MANAGER_TAG to ${FUNCNAME[0]}}"
    : "${2?Pass ENDPOINT to ${FUNCNAME[0]}}"
    : "${3?Pass ETH_PRIVATE_KEY to ${FUNCNAME[0]}}"
    : "${4?Pass GAS_PRICE to ${FUNCNAME[0]}}"
    : "${5?Pass NETWORK to ${FUNCNAME[0]}}"
    : "${6?Pass ETHERSCAN to ${FUNCNAME[0]}}"
    echo Going to run $SM_IMAGE_NAME:$1 docker container...

    mkdir -p $DIR/contracts_data/openzeppelin

    rm $DIR/contracts_data/skale-manager-* || true

    deploy="npx hardhat run migrations/deploy.ts --network custom"
    post_deploy="cp .openzeppelin/* openzeppelin-artifacts/"
    cmd="${deploy} && ${post_deploy}"
    echo CMD $cmd

    docker rm -f $SM_IMAGE_NAME || true
    docker pull skalenetwork/$SM_IMAGE_NAME:$1
    docker run \
        --name $SM_IMAGE_NAME \
        -v $DIR/contracts_data:/usr/src/manager/data \
        --mount type=volume,dst=/usr/src/manager/openzeppelin-artifacts,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=$DIR/contracts_data/openzeppelin \
        --network $DOCKER_NETWORK \
        -e ENDPOINT=$2 \
        -e PRIVATE_KEY=$3 \
        -e GASPRICE=$4 \
        -e ETHERSCAN=$6 \
        skalenetwork/$SM_IMAGE_NAME:$1 \
        /bin/bash -c "$cmd"

    echo Copying $DIR/contracts_data/skale-manager-*-abi.json to $DIR/contracts_data/manager.json
    cp $DIR/contracts_data/skale-manager-*-abi.json $DIR/contracts_data/manager.json
    cp $DIR/contracts_data/skale-manager-*-contracts.json $DIR/contracts_data/manager-contracts.json
    docker rm -f $SM_IMAGE_NAME || true
}


deploy_mirage () {
    : "${1?Pass MIRAGE_TAG to ${FUNCNAME[0]}}"
    : "${2?Pass ENDPOINT to ${FUNCNAME[0]}}"
    : "${3?Pass PRIVATE_KEY to ${FUNCNAME[0]}}"
    : "${4?Pass GAS_PRICE to ${FUNCNAME[0]}}"
    : "${5?Pass NETWORK to ${FUNCNAME[0]}}"
    : "${6?Pass ETHERSCAN to ${FUNCNAME[0]}}"
    : "${7?Pass CHAIN_NAME to ${FUNCNAME[0]}}"
    : "${8?Pass TARGET to ${FUNCNAME[0]}}"
    : "${9?Pass MAINNET_ENDPOINT to ${FUNCNAME[0]}}"
    echo Going to run $MIRAGE_IMAGE_NAME:$1 docker container...

    mkdir -p $DIR/contracts_data/openzeppelin
    cmd="yarn hardhat run migrations/deploy.ts --network custom"

    docker rm -f $MIRAGE_IMAGE_NAME || true
    docker pull skalenetwork/$MIRAGE_IMAGE_NAME:$1
    docker run \
        --name $MIRAGE_IMAGE_NAME \
        -v $DIR/contracts_data:/usr/src/manager/data \
        --network $DOCKER_NETWORK \
        -e ENDPOINT=$2 \
        -e PRIVATE_KEY=$3 \
        -e GASPRICE=$4 \
        -e ETHERSCAN=$6 \
        -e CHAIN_NAME=$7 \
        -e TARGET=$8 \
        -e MAINNET_ENDPOINT=$9 \
        skalenetwork/$MIRAGE_IMAGE_NAME:$1 \
        /bin/bash -c "$cmd"

    echo Copying $DIR/contracts_data/mirage-manager-${MIRAGE_TAG}-* to $DIR/contracts_data/mirage.json
    cp $DIR/contracts_data/mirage-manager-${MIRAGE_TAG}-* $DIR/contracts_data/mirage.json
    docker rm -f $MIRAGE_IMAGE_NAME || true
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

    SM_ABI_FILEPATH=$DIR/contracts_data/manager.json
    if [ ! -f $SM_ABI_FILEPATH ]; then
        echo "$SM_ABI_FILEPATH file not found!"
        exit 3
    fi

    echo Going to run $ALLOCATOR_IMAGE_NAME:$1 docker container...

    docker rm -f $ALLOCATOR_IMAGE_NAME || true

     mkdir -p $DIR/allocator_contracts_data/openzeppelin

    docker pull skalenetwork/$ALLOCATOR_IMAGE_NAME:$1

    DEPLOY_TIMEOUT=1200
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
        sleep $DEPLOY_TIMEOUT

    DEPLOY_CMD="npx hardhat run migrations/deploy.ts --network custom || true"

    docker exec $ALLOCATOR_IMAGE_NAME bash -c "cp /usr/src/manager_data/manager.json /usr/src/allocator/scripts/manager.json"
    docker exec $ALLOCATOR_IMAGE_NAME bash -c "$DEPLOY_CMD"

    echo Copying $DIR/allocator_contracts_data/skale-allocator-* to $DIR/allocator_contracts_data/allocator.json
    cp $DIR/allocator_contracts_data/skale-allocator-* $DIR/allocator_contracts_data/allocator.json

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
    : "${5?Pass SKALE_MANAGER_ADDRESS to ${FUNCNAME[0]}}"
    echo Going to run $IMA_IMAGE_NAME:$1 docker container...

    mkdir -p $DIR/contracts_data/ima-openzeppelin

    docker rm -f $IMA_IMAGE_NAME || true
    docker pull skalenetwork/$IMA_IMAGE_NAME:$1

    deploy="pwd && ls -altr && yarn deploy-to-mainnet"
    post_deploy="cp .openzeppelin/* openzeppelin-artifacts/"
    cmd="${deploy} && ${post_deploy}"
    echo CMD $cmd

    docker run \
        --name $IMA_IMAGE_NAME \
        -v $DIR/contracts_data:/app/data \
        --mount type=volume,dst=/app/openzeppelin-artifacts,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=$DIR/contracts_data/ima-openzeppelin \
        --network $DOCKER_NETWORK \
        -e URL_W3_ETHEREUM=$2 \
        -e PRIVATE_KEY_FOR_ETHEREUM=$3 \
        -e GASPRICE=$4 \
        -e SKALE_MANAGER_ADDRESS=$5 \
        -e NETWORK_FOR_ETHEREUM="mainnet" \
        skalenetwork/$IMA_IMAGE_NAME:$1 \
        bash -c "$cmd"

    echo "Copying $DIR/contracts_data/proxyMainnet.json -> $DIR/contracts_data/ima.json"
    cp $DIR/contracts_data/proxyMainnet.json $DIR/contracts_data/ima.json
    docker rm -f $IMA_IMAGE_NAME || true
}


run_anvil () {
    docker run -d --network host --name anvil ghcr.io/foundry-rs/foundry:rc-3 "anvil --gas-price 0 --block-base-fee-per-gas 0 --disable-min-priority-fee" || true
    sleep 15
    export ANVIL_PRIVATE_KEY=$(docker logs anvil 2>&1 | grep -A 10 "Private Keys" | grep "(0)" | awk '{print $2}')
    echo "ANVIL_PRIVATE_KEY exported to the env: $ANVIL_PRIVATE_KEY"
    echo $ANVIL_PRIVATE_KEY > $DIR/private_key.txt
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
    if ! docker inspect "${SGX_WALLET_CONTAINER_NAME}" >/dev/null 2>&1; then
        docker pull $SGX_WALLET_IMAGE_NAME
        docker run -d -p 1026-1031:1026-1031 --name $SGX_WALLET_CONTAINER_NAME $SGX_WALLET_IMAGE_NAME -s -y
    fi
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

manager_address () {
    SM_ABI_FILEPATH=${ABI_FILEPATH:="$DIR/contracts_data/manager.json"}
    export MANAGER_CONTRACTS=$(jq -r '.skale_manager_address' "$SM_ABI_FILEPATH")
    echo $MANAGER_CONTRACTS
}

ima_address () {
    IMA_ABI_FILEPATH=${IMA_ABI_FILEPATH:="$DIR/contracts_data/ima.json"}
    export IMA_CONTRACTS=$(jq -r '.message_proxy_mainnet_address' "$IMA_ABI_FILEPATH")
    echo $IMA_CONTRACTS
}

allocator_address () {
    ALLOCATOR_ABI_FILEPATH=${ALLOCATOR_ABI_FILEPATH:="$DIR/allocator_contracts_data/allocator.json"}
    export ALLOCATOR_CONTRACTS=$(jq -r '.allocator_address' "$ALLOCATOR_ABI_FILEPATH")
    echo $ALLOCATOR_CONTRACTS
}

mirage_address () {
    MIRAGE_ABI_FILEPATH=${MIRAGE_ABI_FILEPATH:="$DIR/contracts_data/mirage.json"}
    export MIRAGE_CONTRACTS=$(jq -r '.Committee' "$MIRAGE_ABI_FILEPATH")
    echo $MIRAGE_CONTRACTS
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ "$#" -gt 0 ]]; then
        COMMAND=$1
        shift
        if declare -f "$COMMAND" > /dev/null; then
            "$COMMAND" "$@"
        else
            echo "Error: '$COMMAND' is not a valid function name." >&2
            exit 1
        fi
    else
        echo "Usage: bash $0 <function_name> [parameters...]"
        exit 1
    fi
fi
