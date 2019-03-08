USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "$FILENAME" AS row
CREATE (t:Transaction {hash: row.hash})
	SET 
		t.hash = row.hash,
		t.size = toInteger(row.size),
		t.virtual_size = toInteger(row.virtual_size),
		t.version = toInteger(row.version),
		t.lock_time = toInteger(row.lock_time),
		t.is_coinbase = row.is_coinbase,
		t.input_count = toInteger(row.input_count),
		t.output_count = toInteger(row.output_count)
WITH t, row
   MATCH (b:Block {height: row.block_number})	
   CREATE (t)-[:at]->(b);
