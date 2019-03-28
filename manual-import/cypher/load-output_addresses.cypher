USING PERIODIC COMMIT 100000
LOAD CSV WITH HEADERS FROM "{{uri}}" AS row
WITH DISTINCT row.address as address
MERGE (a:Address {address_string: address});

USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "{{uri}}" AS row
MATCH (o:Output {tx_hash: row.hash, output_index: toInteger(row.index)})
MATCH (a:Address {address_string: row.address})
MERGE (a)<-[:owned]-(o);
