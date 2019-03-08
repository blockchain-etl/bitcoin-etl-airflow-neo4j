USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "$FILENAME" AS row
MATCH (i:Output {tx_hash: row.spent_transaction_hash, output_index: row.spent_output_index})
	SET 
		i.input_index = row.index,
		i.is_unspent = toBoolean(false),
		i.spending_tx = row.spent_transaction_hash
WITH i, row		
    MATCH (t:Transaction {hash: i.tx_hash})
    CREATE (i)-[:sent]->(t);
