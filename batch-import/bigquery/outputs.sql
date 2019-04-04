SELECT
  CONCAT(o.transaction_hash, '-', cast(o.index AS STRING)),
  o.transaction_hash as tx_hash,
  o.`index` as output_index,
  o.required_signatures,
  o.type,
  o.value,
  IF(i.transaction_hash IS NULL, false, true) AS is_spent,
  i.index,
  i.transaction_hash
FROM `bigquery-public-data.crypto_bitcoin.outputs` AS o
LEFT JOIN `bigquery-public-data.crypto_bitcoin.inputs` AS i
  ON o.transaction_hash = i.transaction_hash AND
     o.index = i.spent_output_index
WHERE o.block_timestamp < '2010-01-01'
  AND i.block_timestamp < '2010-01-01'
  AND o.transaction_hash NOT IN ('d5d27987d2a3dfc724e359870c6644b40e497bdc0589a033220fe15429d88599',
                                 'e3bf3d07d4b0375638d5f1db5255fe07ba2c4cb067cd81b84ee974b6585fb468')
