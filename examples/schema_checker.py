"""
This script is aimed at checking that all elements in the schema are present.

It is used mainly for checking that imports happen correctly.
"""

import argparse
from neo4j import GraphDatabase


class Checker(object):

    def __init__(self, uri, user, password, block_number, txn):
        self.block_number = block_number
        self.txn = txn

        self._driver = GraphDatabase.driver(uri, auth=(user, password))

    def close(self):
        self._driver.close()

    def _check_block_exists(self):
        with self._driver.session() as session:
            result = session.read_transaction(self.match_block_number, self.block_number)
            records = [record for record in result]
            assert len(records) == 1, "Failed to retrieve exactly one block from the DB"

    @staticmethod
    def match_block_number(tx, block_number):
        result = tx.run("MATCH (block:Block) where block.height={block_number} "
                        "RETURN (block)", {"block_number": block_number})
        return result

    def run_checks(self):
        self._check_block_exists()


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
        print("One of the assertions failed with message: {}".format(e.message))



if __name__ == '__main__':
    main()

