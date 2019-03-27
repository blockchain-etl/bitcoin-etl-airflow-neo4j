USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM '{{uri}}' AS row
CREATE (t:Transaction {
  hash:            row.hash,
  block_height:    toInteger(row.block_number),
  block_timestamp: datetime(row.block_timestamp),
  size:            toInteger(row.size),
  virtual_size:    toInteger(row.virtual_size),
  version:         toInteger(row.version),
  lock_time:       toInteger(row.lock_time),
  is_coinbase:     row.is_coinbase,
  input_count:     toInteger(row.input_count),
  output_count:    toInteger(row.output_count)
});

MERGE (t)-[:at]->(b);
