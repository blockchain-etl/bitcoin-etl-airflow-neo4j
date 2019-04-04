select
   transaction_hash,
   CONCAT(transaction_hash, '-', CAST(index AS STRING))
FROM `bigquery-public-data.crypto_bitcoin.outputs` AS o
WHERE block_timestamp < '2010-01-01'

