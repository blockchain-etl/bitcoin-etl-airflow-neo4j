MATCH (t:Transaction)
MATCH (b:Block {height: t.block_height})
CREATE (t)-[:at]->(b);