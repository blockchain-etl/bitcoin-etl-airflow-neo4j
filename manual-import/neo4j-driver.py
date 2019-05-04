from neo4j import GraphDatabase
import logging
import sys
import os

NEO4J_USER = os.getenv("NEO4J_USER", "neo4j")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD", "n304j")
NEO4J_HOST = os.getenv("NEO4J_HOST", "localhost")


def main():
    neo4j_driver = GraphDatabase.driver("bolt://{}:7687".format(NEO4J_HOST), auth=(NEO4J_USER, NEO4J_PASSWORD))
    with neo4j_driver.session() as session, open('query.cypher', 'r') as queryfile:
        result = session.run(queryfile.read(), timeout=30 * 60)
        logging.info("Execution of load into Neo4J returned: %s", result.summary().counters)


if __name__ == '__main__':
    main()
