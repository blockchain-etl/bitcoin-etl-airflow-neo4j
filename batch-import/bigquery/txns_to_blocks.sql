SELECT
  t.block_number,
  t.hash
FROM `bigquery-public-data.crypto_bitcoin.transactions` AS t
WHERE block_timestamp < '2010-01-01'
