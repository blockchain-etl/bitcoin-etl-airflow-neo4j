USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "{{uri}}" AS row
MATCH (o:Output {tx_hash: row.hash, output_index: toInteger(row.index)})
MERGE (a:Address {address_string: row.address})
MERGE (a)<-[:owned]-(o);
