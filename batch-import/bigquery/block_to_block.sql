select
   number-1,
   number
FROM `bigquery-public-data.crypto_bitcoin.blocks` as blocks
WHERE timestamp < '2019-01-01'
  AND number > 0