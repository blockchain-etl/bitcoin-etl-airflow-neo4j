CREATE CONSTRAINT ON (b:Block) ASSERT b.height IS UNIQUE;
CREATE CONSTRAINT ON (t:Transaction) ASSERT (t.block_height, t.hash) IS NODE KEY;
CREATE CONSTRAINT ON (o:Output) ASSERT (o.block_height, o.hash, o.output_index) IS NODE KEY;
CREATE CONSTRAINT ON (a:Address) ASSERT a.address_string IS UNIQUE;
