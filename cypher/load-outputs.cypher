USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "$FILENAME" AS row
CREATE (o:Output {tx_hash: row.hash, output_index: row.index})
	SET 
		o.required_signatures = toInteger(row.required_signatures),
		o.type = row.type,
		o.value = toInteger(row.value),
		o.is_unspent = toBoolean(true)
WITH o, row
	MATCH (t:Transaction {hash: o.hash})	
	CREATE (o)<-[:received]-(t);
