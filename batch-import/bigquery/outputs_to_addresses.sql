SELECT
     CONCAT(transaction_hash, '-', CAST(index AS STRING)),
     address
FROM `bigquery-public-data.crypto_bitcoin.outputs` AS o,
     UNNEST(o.addresses) as address
WHERE block_timestamp < '2010-01-01'
