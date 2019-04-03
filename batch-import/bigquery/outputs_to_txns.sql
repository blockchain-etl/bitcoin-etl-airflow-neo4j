select
   CONCAT(transaction_hash, '-', CAST(index AS STRING)),
   transaction_hash
FROM `bigquery-public-data.crypto_bitcoin.outputs` AS o
WHERE block_timestamp < '2010-01-01'

