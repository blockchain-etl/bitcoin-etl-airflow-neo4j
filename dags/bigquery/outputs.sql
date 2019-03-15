SELECT t.`hash`,
       o.index,
       o.required_signatures,
       o.type,
       o.value
FROM `bigquery-public-data.crypto_bitcoin.transactions` AS t,
     UNNEST(t.outputs) AS o
WHERE block_timestamp >= '{{ds}}' AND block_timestamp < TIMESTAMP_ADD('{{ds}}', INTERVAL 1 DAY)
