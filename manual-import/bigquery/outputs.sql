SELECT t.`hash`,
       o.index,
       o.required_signatures,
       o.type,
       o.value
FROM `bigquery-public-data.crypto_bitcoin.transactions` AS t,
     UNNEST(t.outputs) AS o
WHERE block_number <= 300
-- WHERE DATE(block_timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
--   AND DATE(block_timestamp) < CURRENT_DATE()
