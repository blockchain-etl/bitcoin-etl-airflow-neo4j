USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "$FILENAME" AS row
MATCH (o:Output {tx_hash: row.hash, output_index: row.index})
MERGE (a:Address {address_string: row.address})
MERGE (a)-[:received]->(o);
