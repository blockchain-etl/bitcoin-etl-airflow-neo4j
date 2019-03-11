CREATE INDEX ON :Transaction(hash);
CREATE INDEX ON :Block(height);
CREATE INDEX ON :Output(tx_hash, output_index);
CREATE INDEX ON :Address(address_string);


