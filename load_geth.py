import logging
import sys
import time

from skale import Skale
from web3.exceptions import TransactionNotFound

logger = logging.getLogger(__name__)


def get_latest_block_timestamp(skale):
    return skale.web3.eth.getBlock("latest")["timestamp"]


class Filter:
    def __init__(self, skale, schain_name, n, all_reciepts=False):
        self.skale = skale
        self.group_index = skale.web3.sha3(text=schain_name)
        self.group_index_str = self.skale.web3.toHex(self.group_index)
        self.first_unseen_block = -1
        self.dkg_contract = skale.dkg.contract
        self.dkg_contract_address = skale.dkg.address
        self.all_reciepts = all_reciepts
        self.event_hash = ""
        self.n = n
        self.t = (2 * n + 1) // 3

    def check_event(self, receipt):
        logs = receipt['logs']
        if len(logs) == 0:
            return False
        if len(logs[0]['topics']) < 2:
            return False
        if logs[0]['topics'][0].hex() != self.event_hash:
            return False
        if logs[0]['topics'][1].hex() != self.group_index_str:
            return False
        return True

    def parse_event(self, receipt):
        node_index = int(receipt['logs'][0]['topics'][2].hex()[2:], 16)
        return node_index

    def get_events(self, from_channel_started_block=False):
        if self.first_unseen_block == -1 or from_channel_started_block:
            start_block = self.dkg_contract.functions.getChannelStartedBlock(
                self.group_index
            ).call()
        else:
            start_block = self.first_unseen_block
        events = []

        if self.all_reciepts:
            start_block = 12297661
            current_block = start_block + 20
            for block_number in range(start_block, current_block + 1):
                print("BLOCK", block_number - start_block)
                start_time = time.time()
                block = self.skale.web3.eth.getBlock(block_number)
                finish_time = time.time()
                print(round(finish_time - start_time, 2), 'seconds')
                txns = block["transactions"]
                start_time = time.time()
                for tx in txns:
                    try:
                        receipt = self.skale.web3.eth.getTransactionReceipt(tx)

                        if not self.check_event(receipt):
                            continue
                        else:
                            events.append(self.parse_event(receipt))
                    except TransactionNotFound:
                        pass
                finish_time = time.time()
                print(round(finish_time - start_time, 2), 'seconds')
                self.first_unseen_block = block_number + 1
        else:
            start_block = 12297661
            current_block = start_block + 200
            for block_number in range(start_block, current_block + 1):
                print("BLOCK", block_number - start_block)
                start_time = time.time()
                block = self.skale.web3.eth.getBlock(block_number,
                                                     full_transactions=True)
                finish_time = time.time()
                print(round(finish_time - start_time, 2), 'seconds')
                txns = block["transactions"]
                start_time = time.time()
                for tx in txns:
                    try:
                        if tx["to"] != self.dkg_contract_address:
                            continue
                        receipt = self.skale.web3.eth.getTransactionReceipt(
                            tx["hash"]
                        )

                        if not self.check_event(receipt):
                            continue
                        else:
                            events.append(self.parse_event(receipt))
                    except TransactionNotFound:
                        pass
                finish_time = time.time()
                print(round(finish_time - start_time, 5), 'seconds')
                self.first_unseen_block = block_number + 1
        return events


def main():
    endpoint = sys.argv[1]
    abi_filepath = sys.argv[2]
    skale = Skale(endpoint, abi_filepath)

    schain_name = "raspy-mintaka"
    n = 16

    dkg_filter = Filter(skale, schain_name, n)
    start_time = time.time()
    dkg_filter.get_events()
    finish_time = time.time()
    first_time = int(finish_time - start_time)
    print(f'FINISH. {first_time} elapsed')

    dkg_filter = Filter(skale, schain_name, n, all_reciepts=True)
    start_time = time.time()
    dkg_filter.get_events()
    finish_time = time.time()
    second_time = int(finish_time - start_time)
    print(f'FINISH. {second_time} elapsed')

    print(f'First time {first_time}')
    print(f'Second time {second_time}')


if __name__ == '__main__':
    main()
