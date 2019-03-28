CREATE CONSTRAINT ON (b:Block) ASSERT b.height IS UNIQUE;
CREATE CONSTRAINT ON (a:Address) ASSERT a.address_string IS UNIQUE;

CREATE INDEX ON :Output(tx_hash, output_index);
CREATE INDEX ON :Transaction(hash);

