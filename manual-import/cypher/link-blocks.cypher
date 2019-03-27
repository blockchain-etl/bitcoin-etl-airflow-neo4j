MATCH (_b:block)
MATCH (b:Block {b.height: _b.height + 1})
CREATE (_b)->[:next]->(b);