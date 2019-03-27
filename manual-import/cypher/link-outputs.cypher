USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "{{uri}}" AS row
MATCH (t:Transaction {hash: row.hash, block_height: toInteger(row.block_height)})
MATCH (o:Output {tx_hash: row.hash, output_index: toInteger(row.index)})
MERGE (o)<-[:received]-(t);
