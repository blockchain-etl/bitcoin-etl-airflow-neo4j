"""
This script is aimed at checking that all elements in the schema are present.

It is used mainly for checking that imports happen correctly.
"""

import argparse
from neo4j import GraphDatabase


class Checker(object):

    def __init__(self, uri, user, password, block_number, txn_hash):
        self.block_number = block_number
        self.txn_hash = txn_hash
        self.output_count = -1
        self.input_count = -1

        self._driver = GraphDatabase.driver(uri, auth=(user, password))

    def close(self):
        self._driver.close()

    @staticmethod
    def assert_equals(expected, obtained, message):
        assert expected == obtained, "Expected: {} but obtained: {}.\n {}".format(expected, obtained, message)

    def _check_block_exists(self):
        with self._driver.session() as session:
            result = session.read_transaction(self.match_block, self.block_number)
            records = [record for record in result]
            self.assert_equals(len(records), 1, "Failed to retrieve exactly one block from the DB")

    def _check_transaction_belongs_to_block(self):
        with self._driver.session() as session:
            result = session.read_transaction(self.match_transaction, self.txn_hash)
            records = [record for record in result]
            self.assert_equals(1, len(records), "Failed to retrieve exactly one transaction from the DB")

            transaction = records[0]['txn']
            self.output_count = transaction['output_count']
            self.input_count = transaction['input_count']

            result = session.read_transaction(self.match_transaction_relationship,
                                              "Block",
                                              self.txn_hash)
            records = [record for record in result]
            self.assert_equals(1, len(records), "Failed to retrieve exactly one relationship transaction to block")
            self.assert_equals("at", records[0]["r"].type, "The retrieved relationship is of wrong type")

    def _check_transaction_is_linked_to_outputs_and_inputs(self):
        with self._driver.session() as session:
            result = session.read_transaction(self.match_transaction_relationship, "Output", self.txn_hash)
            records = [record for record in result]
            self.assert_equals(self.output_count, len(records), "Mismatch in the number of retrieved outputs")

    @staticmethod
    def match_input_relationship(tx, txn_hash):
        return tx.run("MATCH (start:Transaction)-[r]-(other:Output) "
                      "WHERE start.hash='{txn_hash}' "
                      "RETURN r".format(txn_hash=txn_hash, other=other))
    @staticmethod
    def match_transaction_relationship(tx, other, txn_hash):
        return tx.run("MATCH (start:Transaction)-[r]-(other:{other}) "
                      "WHERE start.hash='{txn_hash}' "
                      "RETURN r".format(txn_hash=txn_hash, other=other))

    @staticmethod
    def match_transaction(tx, txn_hash):
        result = tx.run("MATCH (txn:Transaction) where txn.hash={hash} "
                        "RETURN (txn)", {"hash": txn_hash})
        return result

    @staticmethod
    def match_block(tx, block_number):
        result = tx.run("MATCH (block:Block) where block.height={block_number} "
                        "RETURN (block)", {"block_number": block_number})
        return result

    def run_checks(self):
        self._check_block_exists()
        self._check_transaction_belongs_to_block()
        self._check_transaction_is_linked_to_outputs_and_inputs()


def main():
    parser = argparse.ArgumentParser(description='Read parameters.')
    parser.add_argument('--block_number', type=int, help='The block we want to check in the DB', required=True)
    parser.add_argument('--txn', help='The transaction belonging to the block we want to check in the DB')
    parser.add_argument('--uri', help='The uri for the Neo4J DB (bolt://<host>:<port>)')
    parser.add_argument('--user', help='The user for the Neo4J DB')
    parser.add_argument('--password', help='The password for the Neo4J DB')

    args = parser.parse_args()

    checker = Checker(args.uri, args.user, args.password, args.block_number, args.txn)

    try:
        checker.run_checks()
        print("All checks passed. Congrats!!")
    except AssertionError as e:
        print("{}".format(e))


if __name__ == '__main__':
    main()

