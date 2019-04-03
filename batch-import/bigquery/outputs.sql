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