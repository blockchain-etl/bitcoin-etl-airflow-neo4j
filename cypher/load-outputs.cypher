USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "$FILENAME" AS row
MERGE (o:Output {tx_hash: row.hash, output_index: toInteger(row.index)})
ON CREATE SET 
		o.required_signatures = toInteger(row.required_signatures),
		o.type = row.type,
		o.value = toInteger(row.value),
		o.is_unspent = toBoolean(true)
WITH o
	MATCH (t:Transaction {hash: o.tx_hash})	
	MERGE (o)<-[:received]-(t);
