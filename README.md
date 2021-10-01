# SKALE Helper bash scripts

> Export the vars in .env into your shell: `export $(egrep -v '^#' .env | xargs)`

## Direct usage

### Available scripts

#### Run specified version of SKALE Manager and login into it

```bash
export MANAGER_TAG=
./helper-scripts/run_skale_manager.sh
```

#### Deploy test skale-manager on ganache

```bash
export ETH_PRIVATE_KEY=
export MANAGER_TAG=
./helper-scripts/deploy_test_manager.sh
```

#### Deploy test skale-manager and IMA on ganache

```bash
export ETH_PRIVATE_KEY=
export MANAGER_TAG=
./helper-scripts/deploy_test_ima.sh
```

#### Deploy test skale-manager + skale-allocator on ganache

```bash
export ETH_PRIVATE_KEY=
export MANAGER_TAG=
export ALLOCATOR_TAG=
./helper-scripts/deploy_test_allocator.sh
```

#### Deploy skale-manager

```bash
export ETH_PRIVATE_KEY=
export MANAGER_TAG=
export ENDPOINT=
export NETWORK=
export GAS_PRICE=
./helper-scripts/deploy_manager.sh
```

#### Deploy IMA

Deploys IMA contracts and links them to already deployed skale-manager. Place SM ABIs to the `helper-scripts/contracts_data/manager.json` to deploy IMA.

```bash
export ETH_PRIVATE_KEY=
export IMA_TAG=
export ENDPOINT=
export NETWORK=
export GAS_PRICE=
./helper-scripts/deploy_ima.sh
```

#### Deploy skale-manager and skale-allocator

```bash
export ETH_PRIVATE_KEY=
export MANAGER_TAG=
export ALLOCATOR_TAG=
export ENDPOINT=
export NETWORK=
./helper-scripts/deploy_manager_allocator.sh
```

#### Deploy skale-allocator and link to skale-manager

You should put `manager.json` (ABI of skale-manager) to `contracts_data` folder in this repo

```bash
export ETH_PRIVATE_KEY=
export ALLOCATOR_TAG=
export ENDPOINT=
export GAS_PRICE=
export NETWORK=

./helper-scripts/deploy_allocator.sh
```

#### Calculate version

```bash
export BRANCH=
export VERSION=
./helper-scripts/calculate_version.sh
```

### Available functions

All scripts that are available in the main helper file:

- deploy_manager
- deploy_allocator
- run_ganache
- run_sgx_simulator

#### Usage example

```bash
source ./helper.sh
deploy_manager $MANAGER_TAG $ENDPOINT $ETH_PRIVATE_KEY $ETHERSCAN
```

## Embeded usage

### Add helper-scripts to your repo

1.Add git submodule to your repo

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