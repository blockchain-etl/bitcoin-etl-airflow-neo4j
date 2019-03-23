USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "{{uri}}" AS row
MERGE (o:Output {tx_hash: row.hash, output_index: toInteger(row.index)})
ON CREATE SET 
		o.required_signatures = toInteger(row.required_signatures),
		o.type = row.type,
		o.value = toInteger(row.value),
		o.is_spent = toBoolean(false)
WITH o, row
	MATCH (t:Transaction {hash: o.tx_hash, block_height: toInteger(row.block_height)})
	MERGE (o)<-[:received]-(t);
