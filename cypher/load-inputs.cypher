USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "$FILENAME" AS row
CREATE (i:Output {tx_hash: row.spent_transaction_hash, output_index: toInteger(row.spent_output_index)})
 SET 
		i.input_index = toInteger(row.index),
		i.is_spent = toBoolean(true),
		i.spending_tx_hash = row.hash
WITH i, row
    MATCH (t:Transaction {hash: row.hash})
    MERGE (i)-[:sent]->(t);
