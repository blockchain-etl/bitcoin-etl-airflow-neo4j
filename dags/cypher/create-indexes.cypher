CREATE CONSTRAINT ON (b:Block) ASSERT b.height IS UNIQUE;
CREATE CONSTRAINT ON (t:Transaction) ASSERT (t.hash, t.block_height) IS NODE KEY;
CREATE CONSTRAINT ON (o:Output) ASSERT (o.tx_hash, o.output_index) IS NODE KEY;
CREATE CONSTRAINT ON (a:Address) ASSERT a.address_string IS UNIQUE;
