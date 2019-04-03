select
   CONCAT(spent_transaction_hash, '-', CAST(spent_output_index AS STRING)),
   transaction_hash
FROM `bigquery-public-data.crypto_bitcoin.inputs` AS i
WHERE block_timestamp < '2010-01-01'
