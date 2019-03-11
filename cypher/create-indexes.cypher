CREATE CONSTRAINT ON (txn:Transaction) ASSERT txn.hash IS UNIQUE;
CREATE CONSTRAINT ON (block:Block) ASSERT block.height IS UNIQUE;

CREATE INDEX ON :Output(tx_hash, output_index);
CREATE INDEX ON :Address(address_string);


