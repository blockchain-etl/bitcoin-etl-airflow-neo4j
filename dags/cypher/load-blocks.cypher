USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "$FILENAME" AS row
MERGE (b:Block {height: toInteger(row.number)})
ON CREATE SET 
	b.hash = row.hash,
	b.size = toInteger(row.size),
	b.stripped_size = toInteger(row.stripped_size),
	b.weight = toInteger(row.weight),
	b.version = row.version,
	b.merkle_root = row.merkle_root,
	b.timestamp = datetime(row.timestamp),
	b.nonce = row.nonce,
	b.bits = row.bits,
	b.transaction_count = toInteger(row.transaction_count),
	b.coinbase_param = row.coinbase_param
WITH b
MATCH (_b: Block {height: b.height - 1})
MERGE (_b)-[:next] ->(b);
