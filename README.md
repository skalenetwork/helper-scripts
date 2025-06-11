# SKALE Helper bash scripts

> Export the vars in .env into your shell: `export $(egrep -v '^#' .env | xargs)`

## Deployment Options

### Deploy SKALE Manager

#### Option 1: Deploy with Local Anvil Node

To deploy using a local Anvil node, set the `RUN_ANVIL` environment variable to `true`. This will automatically start a local Anvil node and use its private key for deployment.

Required environment variables:

* `RUN_ANVIL=true`
* `MANAGER_TAG` (tag for the SKALE Manager version)

Example:

```bash
MANAGER_TAG=<manager_tag> RUN_ANVIL=true bash deploy_manager.sh
```

#### Option 2: Deploy to a Custom Network

To deploy to a custom network, provide the following environment variables:

Required environment variables:

* `ETH_PRIVATE_KEY` (Ethereum private key without the `0x` prefix)
* `ENDPOINT` (Ethereum RPC endpoint)
* `MANAGER_TAG` (tag for the SKALE Manager version)
* `GAS_PRICE` (optional, default: `10000000000`)
* `NETWORK` (optional, default: `custom`)
* `ETHERSCAN` (optional, default: `1234`)

Example:

```bash
ETH_PRIVATE_KEY=<your_private_key> MANAGER_TAG=<manager_tag> ENDPOINT=<rpc_endpoint> GAS_PRICE=<gas_price> NETWORK=<network_name> ETHERSCAN=<etherscan_api_key> bash deploy_manager.sh
```

### Deploy IMA

#### Option 1: Deploy with Local Anvil Node

To deploy using a local Anvil node, set the `RUN_ANVIL` environment variable to `true`. This will automatically start a local Anvil node and use its private key for deployment.

Required environment variables:

* `RUN_ANVIL=true`
* `IMA_TAG` (tag for the IMA version)

Example:

```bash
IMA_TAG=<ima_tag> RUN_ANVIL=true bash deploy_ima.sh
```

#### Option 2: Deploy to a Custom Network

To deploy to a custom network, provide the following environment variables:

Required environment variables:

* `ETH_PRIVATE_KEY` (Ethereum private key without the `0x` prefix)
* `ENDPOINT` (Ethereum RPC endpoint)
* `IMA_TAG` (tag for the IMA version)
* `GAS_PRICE` (optional, default: `10000000000`)
* `NETWORK` (optional, default: `custom`)
* `ETHERSCAN` (optional, default: `1234`)

Example:

```bash
ETH_PRIVATE_KEY=<your_private_key> IMA_TAG=<ima_tag> ENDPOINT=<rpc_endpoint> GAS_PRICE=<gas_price> NETWORK=<network_name> ETHERSCAN=<etherscan_api_key> bash deploy_ima.sh
```

### Deploy Mirage-Manager

#### Option 1: Deploy with Local Anvil Node

Run a local Anvil instance and deploy `mirage-manager` contracts on it:

Required environment variables:

* `RUN_ANVIL=true`
* `MIRAGE_TAG` (tag for the Mirage-Manager version)

Example:

```bash
RUN_ANVIL=true MIRAGE_TAG=0.0.1-develop.6 bash deploy_mirage.sh
```

#### Option 2: Deploy to a Custom Network

Deploy `mirage-manager` contracts to a custom network:

Required environment variables:

* `ETH_PRIVATE_KEY` (Ethereum private key without the `0x` prefix)
* `ENDPOINT` (Ethereum RPC endpoint)
* `MIRAGE_TAG` (tag for the Mirage-Manager version)
* `CHAIN_NAME` chain name what should be migrated
* `TARGET` Skale Manager address for the Ethereum 

Example:

```bash
ETH_PRIVATE_KEY=<your_private_key> ENDPOINT=https://example.com MIRAGE_TAG=0.0.1-develop.6 CHAIN_NAME=<schain-name> TARGET=<skale-manager address> bash deploy_mirage.sh
```


ABI and address of the deployed contracts will be saved in `contracts_data/mirage.json` file.

### Deploy SKALE Allocator

#### Option 1: Deploy with Local Anvil Node

To deploy using a local Anvil node, set the `RUN_ANVIL` environment variable to `true`. This will automatically start a local Anvil node and use its private key for deployment.

Required environment variables:

* `RUN_ANVIL=true`
* `ALLOCATOR_TAG` (tag for the Allocator version)

Example:

```bash
ALLOCATOR_TAG=<allocator_tag> RUN_ANVIL=true bash deploy_allocator.sh
```

#### Option 2: Deploy to a Custom Network

To deploy to a custom network, provide the following environment variables:

Required environment variables:

* `ETH_PRIVATE_KEY` (Ethereum private key without the `0x` prefix)
* `ENDPOINT` (Ethereum RPC endpoint)
* `ALLOCATOR_TAG` (tag for the Allocator version)
* `GAS_PRICE` (optional, default: `10000000000`)
* `NETWORK` (optional, default: `custom`)

Example:

```bash
ETH_PRIVATE_KEY=<your_private_key> ALLOCATOR_TAG=<allocator_tag> ENDPOINT=<rpc_endpoint> GAS_PRICE=<gas_price> NETWORK=<network_name> bash deploy_allocator.sh
```

## Additional Scripts

### Calculate Version

To calculate the version, use the following script:

Required environment variables:

* `BRANCH` (branch name)
* `VERSION` (base version)

Example:

```bash
BRANCH=<branch_name> VERSION=<base_version> ./helper-scripts/calculate_version.sh
```

## Embedded Usage

### Add helper-scripts to your repo

1. Add git submodule to your repo

```bash
git submodule add -b develop https://github.com/skalenetwork/helper-scripts.git
git submodule init
```

2. Update submodule later on

```bash
git submodule update --remote
```

### Add submodules to your Github Actions build

You can use this package: https://github.com/marketplace/actions/checkout-submodules

Just add those lines to the pipeline:

```yml
steps:
- name: Checkout submodules
  uses: textbook/git-checkout-submodule-action@master
  with:
    remote: true
```
