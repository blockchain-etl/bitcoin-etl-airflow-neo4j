USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "{{uri}}" AS row
WITH DISTINCT row.address as address
MERGE (a:Address {address_string: address});

USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "{{uri}}" AS row
MATCH (a:Address {address_string: row.address})
WITH row, a
MATCH (o:Output {tx_hash: row.hash, output_index: toInteger(row.index)})
MERGE (a)<-[:owned]-(o);
