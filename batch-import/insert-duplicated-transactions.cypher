CREATE (t1:Transaction {
  hash: 'd5d27987d2a3dfc724e359870c6644b40e497bdc0589a033220fe15429d88599',
  block_height: 91812,
  block_timestamp: datetime('2010-11-14T17:59:48+00:00'),
  size: 133,
  virtual_size: 133,
  version: 1,
  lock_time: 0,
  is_coinbase: true,
  input_count: 0,
  output_count: 1
});
CREATE (t1:Transaction {
  hash: 'd5d27987d2a3dfc724e359870c6644b40e497bdc0589a033220fe15429d88599',
  block_height: 91842,
  block_timestamp: datetime('2010-11-14T21:04:51+00:00'),
  size: 133,
  virtual_size: 133,
  version: 1,
  lock_time: 0,
  is_coinbase: true,
  input_count: 0,
  output_count: 1
});
CREATE (t1:Transaction {
  hash: 'e3bf3d07d4b0375638d5f1db5255fe07ba2c4cb067cd81b84ee974b6585fb468',
  block_height: 91722,
  block_timestamp: datetime('2010-11-14T08:37:28+00:00'),
  size: 133,
  virtual_size: 133,
  version: 1,
  lock_time: 0,
  is_coinbase: true,
  input_count: 0,
  output_count: 1
});
CREATE (t1:Transaction {
  hash: 'e3bf3d07d4b0375638d5f1db5255fe07ba2c4cb067cd81b84ee974b6585fb468',
  block_height: 91880,
  block_timestamp: datetime('2010-11-15T00:36:19+00:00'),
  size: 133,
  virtual_size: 133,
  version: 1,
  lock_time: 0,
  is_coinbase: true,
  input_count: 0,
  output_count: 1
});

// Link to blocks and outputs
MATCH (b:Block {height: 91812})
MATCH (t:Transaction {block_height: 91812, hash: 'd5d27987d2a3dfc724e359870c6644b40e497bdc0589a033220fe15429d88599'})
MERGE (a:Address {address_string: '16va6NxJrMGe5d2LP6wUzuVnzBBoKQZKom'})
CREATE (o:Output {
   tx_hash: 'd5d27987d2a3dfc724e359870c6644b40e497bdc0589a033220fe15429d88599',
   output_index: 0,
   required_signatures: 1,
   type: 'pubkey',
   value: 5000000000
})
CREATE (a)<-[:owned]-(o)<-[:received]-(t)-[:at]->(b);

MATCH (b:Block {height: 91842})
MATCH (t:Transaction {block_height: 91842, hash: 'd5d27987d2a3dfc724e359870c6644b40e497bdc0589a033220fe15429d88599'})
MERGE (a:Address {address_string: '16va6NxJrMGe5d2LP6wUzuVnzBBoKQZKom'})
CREATE (o:Output {
  tx_hash: 'd5d27987d2a3dfc724e359870c6644b40e497bdc0589a033220fe15429d88599',
  output_index: 0,
  required_signatures: 1,
  type: 'pubkey',
  value: 5000000000
})
CREATE (a)<-[:owned]-(o)<-[:received]-(t)-[:at]->(b);

MATCH (b:Block {height: 91722})
MATCH (t:Transaction {block_height: 91722, hash: 'e3bf3d07d4b0375638d5f1db5255fe07ba2c4cb067cd81b84ee974b6585fb468'})
MERGE (a:Address {address_string: '1GktTvnY8KGfAS72DhzGYJRyaQNvYrK9Fg'})
CREATE (o:Output {
  tx_hash: 'e3bf3d07d4b0375638d5f1db5255fe07ba2c4cb067cd81b84ee974b6585fb468',
  output_index: 0,
  required_signatures: 1,
  type: 'pubkey',
  value: 5000000000
})
CREATE (a)<-[:owned]-(o)<-[:received]-(t)-[:at]->(b);

MATCH (b:Block {height: 91880})
MATCH (t:Transaction {block_height: 91880, hash: 'e3bf3d07d4b0375638d5f1db5255fe07ba2c4cb067cd81b84ee974b6585fb468'})
MERGE (a:Address {address_string: '1GktTvnY8KGfAS72DhzGYJRyaQNvYrK9Fg'})
CREATE (o:Output {
  tx_hash: 'e3bf3d07d4b0375638d5f1db5255fe07ba2c4cb067cd81b84ee974b6585fb468',
  output_index: 0,
  required_signatures: 1,
  type: 'pubkey',
  value: 5000000000
})
CREATE (a)<-[:owned]-(o)<-[:received]-(t)-[:at]->(b);


