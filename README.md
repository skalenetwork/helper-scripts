# SKALE Helper bash scripts

## Direct usage

### Available scripts

#### Deploy test skale-manager on ganache

```bash
export ETH_PRIVATE_KEY=
export MANAGER_TAG=
./helper-scripts/deploy_test_manager.sh
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
./helper-scripts/deploy_manager.sh
```

#### Deploy skale-allocator

```bash
export ETH_PRIVATE_KEY=
export MANAGER_TAG=
export ALLOCATOR_TAG=
export ENDPOINT=
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
deploy_manager $MANAGER_TAG $ENDPOINT $ETH_PRIVATE_KEY
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