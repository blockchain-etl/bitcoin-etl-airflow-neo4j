USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "{{uri}}" AS row
MERGE (t:Transaction {hash: row.hash})
ON CREATE SET 
		t.hash = row.hash,
    t.block_height = toInteger(row.block_number),
    t.block_timestamp = datetime(row.block_timestamp),
		t.size = toInteger(row.size),
		t.virtual_size = toInteger(row.virtual_size),
		t.version = toInteger(row.version),
		t.lock_time = toInteger(row.lock_time),
		t.is_coinbase = toBoolean(row.is_coinbase),
		t.input_count = toInteger(row.input_count),
		t.output_count = toInteger(row.output_count);


USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "{{uri}}" AS row
MATCH (b:Block {height: toInteger(row.block_number)})
WITH b, row
MATCH (t:Transaction {hash: row.hash})
MERGE (t)-[:at]->(b);
