"""
This script is aimed at checking that all elements in the schema are present.

It is used mainly for checking that imports happen correctly.
"""

import argparse
import os
from neo4j import GraphDatabase
from google.cloud import bigquery

import warnings

warnings.filterwarnings("ignore", "Your application has authenticated using end user credentials")


class Checker(object):

    def __init__(self, uri, user, password):
        self._driver = GraphDatabase.driver(uri, auth=(user, password))
        self.bq_client = bigquery.Client()

    def close(self):
        self._driver.close()

    @staticmethod
    def assert_equals(expected, obtained, message):
        assert expected == obtained, "Expected {} from BigQuery but obtained {} from Neo4J.\n {}".format(expected,
                                                                                                         obtained,
                                                                                                         message)

    def check_number_of_blocks(self):
        print("Checking number of blocks")
        # Neo4J
        with self._driver.session() as session:
            result = session.read_transaction(self._retrieve_number_of_nodes, 'Block')
            records = [record for record in result]
            self.assert_equals(len(records), 1, "Failed to retrieve exactly one block from the DB")

            neo4j_num_blocks = records[0]['COUNT(b)']

        # Bigquery
        query = """SELECT
                     COUNT(*) AS num_blocks
                   FROM
                     `bigquery-public-data.crypto_bitcoin.blocks` AS blocks
                   WHERE
                     blocks.number <= 300"""
        query_job = self.bq_client.query(query, location="US")
        bq_num_blocks = 0
        for row in query_job:
            bq_num_blocks = row[0]

        self.assert_equals(bq_num_blocks, neo4j_num_blocks, "Mismatch in the number of blocks")

    @staticmethod
    def _retrieve_number_of_transaction_rels(tx, relation):
        return tx.run("MATCH n=(output:Output)-[:{relation}]-(:Transaction) "
                      "RETURN "
                      "  COUNT(output) AS count, "
                      "  SUM(output.value) AS total".format(relation=relation))

    @staticmethod
    def _retrieve_number_of_nodes(tx, label):
        result = tx.run("MATCH (b:{label}) RETURN COUNT(b)".format(label=label))
        return result

    def check_number_of_transactions(self):
        print("Checking number of transactions")
        # Neo4J
        with self._driver.session() as session:
            result = session.read_transaction(self._retrieve_number_of_nodes, 'Transaction')
            records = [record for record in result]
            self.assert_equals(len(records), 1, "Failed to retrieve exactly one block from the DB")

            neo4j_num_txns = records[0]['COUNT(b)']

        # Bigquery
        query = """SELECT
                     COUNT(*) AS num_blocks
                   FROM
                     `bigquery-public-data.crypto_bitcoin.transactions` AS transactions
                   WHERE
                     transactions.block_number <= 300"""
        query_job = self.bq_client.query(query, location="US")
        bq_num_txns = 0
        for row in query_job:
            bq_num_txns = row[0]

        self.assert_equals(bq_num_txns, neo4j_num_txns, "Mismatch in the number of transactions")

    def check_number_of_inputs(self):
        print("Checking inputs")
        # Neo4J
        with self._driver.session() as session:
            result = session.read_transaction(self._retrieve_number_of_transaction_rels, 'sent')
            records = [record for record in result]
            self.assert_equals(len(records), 1, "Failed to retrieve exactly one block from the DB")

            neo4j_num_inputs = records[0]['count']
            neo4j_total_inputs = records[0]['total']

        # Bigquery
        query = """
                   SELECT
                     COUNT(inputs)
                   , SUM(inputs.value) AS num_inputs
                   FROM
                     `bigquery-public-data.crypto_bitcoin.transactions` AS transactions,
                     UNNEST(transactions.inputs) as inputs
                   WHERE
                     transactions.block_number <= 300"""
        query_job = self.bq_client.query(query, location="US")
        bq_num_inputs = 0
        bq_total_inputs = 0
        for row in query_job:
            bq_num_inputs = row[0]
            bq_total_inputs = row[1]

        self.assert_equals(bq_num_inputs, neo4j_num_inputs, "Mismatch in the number of inputs")
        self.assert_equals(bq_total_inputs, neo4j_total_inputs, "Mismatch in the summed value of all inputs")

    def check_number_of_outputs(self):
        print("Checking outputs")
        # Neo4J
        with self._driver.session() as session:
            result = session.read_transaction(self._retrieve_number_of_transaction_rels, 'received')
            records = [record for record in result]
            self.assert_equals(len(records), 1, "Failed to retrieve exactly one block from the DB")

            neo4j_num_inputs = records[0]['count']
            neo4j_total_inputs = records[0]['total']

        # Bigquery
        query = """
                   SELECT
                     COUNT(outputs)
                   , SUM(outputs.value) AS num_outputs
                   FROM
                     `bigquery-public-data.crypto_bitcoin.transactions` AS transactions,
                     UNNEST(transactions.outputs) as outputs
                   WHERE
                     transactions.block_number <= 300"""
        query_job = self.bq_client.query(query, location="US")
        bq_num_inputs = 0
        bq_total_inputs = 0
        for row in query_job:
            bq_num_inputs = row[0]
            bq_total_inputs = row[1]

        self.assert_equals(bq_num_inputs, neo4j_num_inputs, "Mismatch in the number of inputs")
        self.assert_equals(bq_total_inputs, neo4j_total_inputs, "Mismatch in the summed value of all inputs")

    @staticmethod
    def _count_number_of_addresses_which_own(tx, relation):
        return tx.run("MATCH (:Transaction)-[:{relation}]-(output:Output)-[:owned]->(address:Address) "
                      "RETURN COUNT(DISTINCT address) AS count".format(relation=relation))

    def check_number_of_addresses_which_own_inputs(self):
        print("Checking addresses which own inputs")
        # Neo4J
        with self._driver.session() as session:
            result = session.read_transaction(self._count_number_of_addresses_which_own, 'sent')
            records = [record for record in result]
            self.assert_equals(len(records), 1, "Failed to retrieve exactly one block from the DB")

            neo4j_num_addresses = records[0]['count']

        # Bigquery
        query = """
            SELECT
              COUNT(DISTINCT address)
            FROM
              `bigquery-public-data.crypto_bitcoin.inputs` AS inputs
            CROSS JOIN
              UNNEST(inputs.addresses) AS address
            WHERE
             inputs.block_number <= 300"""
        query_job = self.bq_client.query(query, location="US")
        bq_num_addresses = 0
        for row in query_job:
            bq_num_addresses = row[0]

        self.assert_equals(bq_num_addresses, neo4j_num_addresses, "Mismatch in the number of input addresses")

    def check_number_of_addresses_which_own_outputs(self):
        print("Checking addresses which own outputs")
        # Neo4J
        with self._driver.session() as session:
            result = session.read_transaction(self._count_number_of_addresses_which_own, 'received')
            records = [record for record in result]
            self.assert_equals(len(records), 1, "Failed to retrieve exactly one block from the DB")

            neo4j_num_addresses = records[0]['count']

        # Bigquery
        query = """
            SELECT
              COUNT(DISTINCT address)
            FROM
              `bigquery-public-data.crypto_bitcoin.outputs` AS outputs
            CROSS JOIN
              UNNEST(outputs.addresses) AS address
            WHERE
             outputs.block_number <= 300"""
        query_job = self.bq_client.query(query, location="US")
        bq_num_addresses = 0
        for row in query_job:
            bq_num_addresses = row[0]

        self.assert_equals(bq_num_addresses, neo4j_num_addresses, "Mismatch in the number of output addresses")

    def check_not_null_attributes(self):
        print("Checking the not nullness of required parameters")

        def assert_not_nulls(kind_of_node, query):
            with self._driver.session() as session:
                result = session.run(query)
                records = [record for record in result]
                neo4j_nulls = records[0]['count']

                self.assert_equals(0, neo4j_nulls,
                                   "Nulls found in required attributes "
                                   "of {kind_of_node} nodes".format(kind_of_node=kind_of_node))

        assert_not_nulls("Block", """
                         MATCH (b:Block) WHERE
                                b.hash IS null OR
                                b.size IS null OR
                                b.stripped_size IS null OR
                                b.weight IS null OR
                                b.version IS null OR
                                b.merkle_root IS null OR
                                b.timestamp IS null OR
                                b.nonce IS null OR
                                b.bits IS null OR
                                b.transaction_count IS null OR
                                b.coinbase_param IS null
                            RETURN COUNT(b) AS count""")
        assert_not_nulls("Transaction", """MATCH (t:Transaction)
                            WHERE
                                t.hash IS null or
                                t.size IS null or
                                t.virtual_size IS null or
                                t.version IS null or
                                t.lock_time IS null or
                                t.is_coinbase IS null or
                                t.input_count IS null or
                                t.output_count IS null
                            RETURN COUNT(t) AS count""")
        assert_not_nulls("Output", """MATCH (o:Output)<-[:received]-(:Transaction)
                            WHERE
                                o.required_signatures IS null or
                                o.type IS null or
                                o.value IS null or
                                o.is_spent IS null or
                                o.tx_hash IS null or
                                o.output_index IS null
                            RETURN COUNT(o) AS count""")
        assert_not_nulls("Input", """MATCH (o:Output)-[:sent]->(:Transaction)
                            WHERE
                                o.required_signatures IS null or
                                o.type IS null or
                                o.value IS null or
                                o.is_spent IS null or
                                o.tx_hash IS null or
                                o.output_index IS null or
                                o.input_index IS null or
                                o.spending_tx_hash IS null
                            RETURN COUNT(o) AS count""")
        assert_not_nulls("Address", """MATCH (a:Address)
                            WHERE
                                a.address_string IS null
                            RETURN COUNT(a) AS count""")

    def check_orphans(self):
        print("Checking the existence of orphans")

        def match_counts_signaling_orphans(kind, query):
            with self._driver.session() as session:
                result = session.run(query)
                records = [record for record in result]
                expected = records[0]['expected']
                obtained = records[0]['obtained']

                self.assert_equals(expected, obtained, "Orphans found of kind {kind}".format(kind=kind))

        match_counts_signaling_orphans("Non linked blocks", """
            MATCH links=(__b:Block)-[:next]->(_b:Block)
            WITH COUNT(links) as num_links
            MATCH (b:Block)
            RETURN COUNT(DISTINCT b.hash) as expected, num_links + 1 as obtained
            """)

        match_counts_signaling_orphans("Transactions linked to blocks",
                                       """MATCH links=(_t:Transaction)-[:at]->(:Block)
                                          WITH COUNT(links) as num_txns_linked_to_blocks
                                          MATCH (t:Transaction)
                                          RETURN COUNT(t) as expected, num_txns_linked_to_blocks as obtained""")

        match_counts_signaling_orphans("Inputs without Outputs",
                                       """MATCH links=(:Transaction)-[:received]->(o:Output)-[:sent]->(:Transaction)
                                          WITH COUNT(links) as full_link
                                          MATCH inputs=(o:Output)-[:sent]->(:Transaction)
                                          RETURN full_link as expected, COUNT(inputs) as obtained""")

        match_counts_signaling_orphans('Addresses', """
                                        MATCH (a:Address)
                                        WITH COUNT(DISTINCT a.address_string) as expected
                                        MATCH (_a:Address)<-[:owned]-(:Output)
                                        RETURN expected, COUNT(DISTINCT _a.address_string) as obtained""")

    def check_duplicates(self):
        print("Checking the existence of duplicates")

        def assert_non_duplication(kind, query):
            with self._driver.session() as session:
                result = session.run(query)
                records = [record for record in result]
                self.assert_equals(0, len(records), "Duplicates found in node kind {kind}".format(kind=kind))

        assert_non_duplication("Blocks", """MATCH (b:Block)
                                            WITH b.hash as block_hash, count(*) as cnt
                                            WHERE cnt > 1
                                            RETURN block_hash, cnt""")
        assert_non_duplication("Transactions", """MATCH (t:Transaction)
                                                  WITH t.hash as tx_hash, count(*) as cnt
                                                  WHERE cnt > 1
                                                  RETURN tx_hash, cnt""")
        assert_non_duplication("Outputs", """MATCH (o:Output)
                                             WITH o.tx_hash as tx_hash, o.output_index as output_index, count(*) as cnt
                                             WHERE cnt > 1
                                             RETURN tx_hash, output_index, cnt""")
        assert_non_duplication("Addresses", """MATCH (a:Address)
                                               WITH a.address_string as address_string, count(*) as cnt
                                               WHERE cnt > 1
                                               RETURN address_string, cnt""")

    def run_checks(self):
        self.check_number_of_blocks()
        self.check_number_of_transactions()
        self.check_number_of_inputs()
        self.check_number_of_outputs()
        self.check_number_of_addresses_which_own_inputs()
        self.check_not_null_attributes()
        self.check_orphans()
        self.check_duplicates()


def main():
    parser = argparse.ArgumentParser(description='Read parameters.')
    parser.add_argument('--uri', help='The uri for the Neo4J DB (bolt://<host>:<port>)',
                        default=os.getenv('NEO_URI'))
    parser.add_argument('--user', help='The user for the Neo4J DB', default='neo4j')
    parser.add_argument('--password', help='The password for the Neo4J DB', default=os.getenv('NEO_PASSWORD'))

    args = parser.parse_args()

    checker = Checker(args.uri, args.user, args.password)

    try:
        checker.run_checks()
        print("All checks passed. Congrats!!")
    except AssertionError as e:
        print("{}".format(e))


if __name__ == '__main__':
    main()
