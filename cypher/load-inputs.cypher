USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "$FILENAME" AS row
MERGE (i:Output {tx_hash: row.spent_transaction_hash, output_index: toInteger(row.spent_output_index)})
ON CREATE SET 
		i.input_index = toInteger(row.index),
		i.is_unspent = toBoolean(false),
		i.spending_tx_hash = row.hash
WITH i, row
    MATCH (t:Transaction {hash: row.tx_hash})
    MERGE (i)-[:sent]->(t);
