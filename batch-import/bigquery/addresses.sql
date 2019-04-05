SELECT DISTINCT address
FROM `bigquery-public-data.crypto_bitcoin.outputs` AS o,
     UNNEST(o.addresses) as address
WHERE block_timestamp < '2019-01-01'
