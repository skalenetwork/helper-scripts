import json
import os
import sys
from jinja2 import Environment


def get_node_id(base_dir):
    config_path = os.path.join(
        base_dir,
        '.skale/node_data/node_config.json'
    )
    with open(config_path) as config_file:
        return json.load(config_file)['node_id']


def get_node_ip(base_dir):
    config_path = os.path.join(
        base_dir,
        '.skale/node_data/node_config.json'
    )
    with open(config_path) as config_file:
        return json.load(config_file)['node_ip']


def get_contract_address(base_dir):
    abi_path = os.path.join(
        base_dir,
        '.skale/contracts_info/manager.json'
    )
    with open(abi_path) as abi_file:
        return json.load(abi_file)['skale_manager_address']


def get_template(base_dir):
    template_path = os.path.join(
        base_dir,
        '.skale/config/filebeat.yml.j2'
    )
    with open(template_path) as template_file:
        return template_file.read()


def save_filebeat_config(instantiated_template, base_dir):
    filebeat_config_path = os.path.join(
        base_dir,
        '.skale/config/filebeat.yml'
    )
    with open(filebeat_config_path, 'w') as c_file:
        return c_file.write(instantiated_template)


def main():
    base_dir = sys.argv[1]
    template = get_template(base_dir)
    data = {
        'ip': get_node_ip(base_dir),
        'id': get_node_id(base_dir),
        'contract_address': get_contract_address(base_dir)
    }
    instantiated_template = Environment().from_string(template).render(data)
    save_filebeat_config(instantiated_template, base_dir)


if __name__ == '__main__':
    main()
