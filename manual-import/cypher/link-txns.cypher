MATCH (t:Transaction)
MATCH (b:Block {height: t.block_number})
CREATE (t)-[:at]->(b);