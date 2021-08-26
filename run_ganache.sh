#!/usr/bin/env bash
#
# This script can be used to deploy specified version of skale-manager to the provided endpoint
# with given private key
#

set -e

: "${ETH_PRIVATE_KEY?Need to set ETH_PRIVATE_KEY}"

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/helper.sh

# create_test_docker_network
run_ganache $ETH_PRIVATE_KEY
