USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "{{uri}}" AS row
CREATE (o:Output {
	tx_hash: row.hash,
	output_index: toInteger(row.index),
	required_signatures: toInteger(row.required_signatures),
	type: row.type,
	value: toInteger(row.value),
	is_spent: toBoolean(false)
});


