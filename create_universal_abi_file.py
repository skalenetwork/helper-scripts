import sys
import json


def merge_files(manager_filepath, allocator_filepath, result_filepath):
    manager_abi = read_json(manager_filepath)
    allocator_abi = read_json(allocator_filepath)

    manager_abi.update(allocator_abi)
    write_json(result_filepath, manager_abi)
    print('Results saved to ', result_filepath)


def read_json(path):
    with open(path) as data_file:
        return json.loads(data_file.read())


def write_json(path, content):
    with open(path, 'w') as outfile:
        json.dump(content, outfile, indent=4)


if __name__ == "__main__":
    MANAGER_FILEPATH = sys.argv[1]
    ALLOCATOR_FILEPATH = sys.argv[2]
    RESULT_FILEPATH = sys.argv[3]

    merge_files(MANAGER_FILEPATH, ALLOCATOR_FILEPATH, RESULT_FILEPATH)
