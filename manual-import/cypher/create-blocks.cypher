USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM '{{uri}}' AS row
CREATE (b:Block {
  height:            toInteger(row.number),
  hash:              row.hash,
  size:              toInteger(row.size),
  stripped_size:     toInteger(row.stripped_size),
  weight:            toInteger(row.weight),
  version:           row.version,
  merkle_root:       row.merkle_root,
  timestamp:         datetime(row.timestamp),
  nonce:             row.nonce,
  bits:              row.bits,
  transaction_count: toInteger(row.transaction_count),
  coinbase_param:    row.coinbase_param
});
