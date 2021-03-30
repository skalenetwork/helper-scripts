#   -*- coding: utf-8 -*-
#
#   This file is part of SKALE.py
#
#   Copyright (C) 2021-Present SKALE Labs
#
#   SKALE.py is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   SKALE.py is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with SKALE.py.  If not, see <https://www.gnu.org/licenses/>.

import os
import yaml


LARGE_DIVIDER = 1
MEDIUM_DIVIDER = 32
TEST_DIVIDER = 32
SMALL_DIVIDER = 128

VOLUME_CHUNK = 512 * SMALL_DIVIDER
DISK_FACTOR = 0.95


class Alloc:
    def to_dict(self):
        return self.values


class ResourceAlloc(Alloc):
    def __init__(self, value, fractional=False):
        self.values = {
            'test4': value / TEST_DIVIDER,
            'test': value / TEST_DIVIDER,
            'small': value / SMALL_DIVIDER,
            'medium': value / MEDIUM_DIVIDER,
            'large': value / LARGE_DIVIDER
        }
        if not fractional:
            for k in self.values:
                self.values[k] = int(self.values[k])


class SChainVolumeAlloc(Alloc):
    def __init__(self, disk_alloc_dict: dict, proportions: dict):
        self.values = {}
        for size_name in disk_alloc_dict:
            self.values[size_name] = {}
            for key, value in proportions.items():
                lim = int(value * disk_alloc_dict[size_name])
                self.values[size_name][key] = lim


class LevelDBAlloc(Alloc):
    def __init__(self, disk_alloc_dict: dict, proportions: dict):
        self.values = {}
        for size_name in disk_alloc_dict:
            self.values[size_name] = {}
            for key, value in proportions.items():
                lim = int(value * disk_alloc_dict[size_name]['skaled_leveldb_storage_part'])
                self.values[size_name][key] = lim


def calculate_free_disk_space(disk_size: int) -> int:
    return int(disk_size * DISK_FACTOR) // VOLUME_CHUNK * VOLUME_CHUNK


def safe_load_yaml(filepath):
    with open(filepath, 'r') as stream:
        try:
            return yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            print(exc)


def save_yaml(filepath, data, comments=None):
    with open(filepath, 'w') as outfile:
        if comments:
            outfile.write(comments)
        yaml.dump(data, outfile, default_flow_style=False)


def generate_disk_alloc(configs: dict, env_type_name: str, schain_allocation: dict) -> ResourceAlloc:
    """Generates disk allocation for the provided env type"""
    disk_size_bytes = configs['envs'][env_type_name]['server']['disk_size_bytes']
    free_disk_space = calculate_free_disk_space(disk_size_bytes)
    disk_alloc = ResourceAlloc(free_disk_space)
    schain_allocation[env_type_name]['disk'] = disk_alloc.to_dict()
    return disk_alloc


def generate_volume_alloc(configs: dict, env_type_name: str, schain_allocation: dict,
                          disk_alloc: ResourceAlloc) -> SChainVolumeAlloc:
    """Generates volume partitioning for the provided env type and disk allocation"""
    proportions = configs['common']['schain']['volume']
    volume_alloc = SChainVolumeAlloc(disk_alloc.to_dict(), proportions)
    schain_allocation[env_type_name]['volume'] = volume_alloc.to_dict()
    return volume_alloc


def generate_leveldb_alloc(configs: dict, env_type_name: str, schain_allocation: dict,
                           volume_alloc: SChainVolumeAlloc) -> LevelDBAlloc:
    """Generates LevelDB partitioning for the provided env type and volume partitioning"""
    leveldb_proportions = configs['common']['schain']['leveldb_storage']
    leveldb_alloc = LevelDBAlloc(volume_alloc.to_dict(), leveldb_proportions)
    schain_allocation[env_type_name]['leveldb'] = leveldb_alloc.to_dict()
    return leveldb_alloc


def generate_schain_allocation(skale_node_path: str) -> None:
    configs_filepath = os.path.join(skale_node_path, 'configs.yml')
    schain_allocation_filepath = os.path.join(skale_node_path, 'schain_allocation.yml')
    configs = safe_load_yaml(configs_filepath)

    schain_allocation = {}
    for env_type_name in configs['envs']:
        schain_allocation[env_type_name] = {}
        disk_alloc = generate_disk_alloc(configs, env_type_name, schain_allocation)
        volume_alloc = generate_volume_alloc(configs, env_type_name, schain_allocation, disk_alloc)
        generate_leveldb_alloc(configs, env_type_name, schain_allocation, volume_alloc)

    save_yaml(
        filepath=schain_allocation_filepath,
        data=schain_allocation,
        comments='# DO NOT MODIFY THIS FILE MANUALLY!\n# Use generate_schain_allocation.py script from helper-scripts repo.\n\n'
    )
    print(f'Generated schain_allocation.yml, results saved to {schain_allocation_filepath}')


if __name__ == "__main__":
    skale_node_path = os.environ['SKALE_NODE_PATH']
    generate_schain_allocation(skale_node_path)
