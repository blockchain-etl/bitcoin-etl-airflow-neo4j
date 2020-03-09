SELECT
  CONCAT(CAST(tout.tx_seq_number AS STRING), '-', cast(o.index AS STRING)),
  tout.tx_seq_number,
  o.`index` as output_index,
  o.required_signatures,
  o.type,
  o.value,
  IF(i.transaction_hash IS NULL, false, true) AS is_spent,
  i.index,
  tinp.tx_seq_number as i_tx_seq_number
FROM `bigquery-public-data.crypto_bitcoin.outputs` AS o
JOIN crypto_bitcoin.txns AS tout
  ON tout.`hash` = o.transaction_hash AND tout.block_number = o.block_number
LEFT JOIN `bigquery-public-data.crypto_bitcoin.inputs` AS i
  ON o.transaction_hash = i.spent_transaction_hash AND
     o.index = i.spent_output_index
JOIN crypto_bitcoin.txns AS tinp
  ON tinp.`hash` = i.transaction_hash AND tinp.block_number = i.block_number
WHERE o.block_timestamp < '2019-01-01'
  AND o.transaction_hash NOT IN ('d5d27987d2a3dfc724e359870c6644b40e497bdc0589a033220fe15429d88599',
                                 'e3bf3d07d4b0375638d5f1db5255fe07ba2c4cb067cd81b84ee974b6585fb468')
