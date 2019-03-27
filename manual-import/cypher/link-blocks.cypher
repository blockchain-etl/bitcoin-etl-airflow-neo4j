MATCH (_b:Block)
MATCH (b:Block {height: _b.height + 1})
CREATE (_b)-[:next]->(b);