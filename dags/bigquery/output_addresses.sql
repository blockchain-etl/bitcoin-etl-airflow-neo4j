SELECT `hash`,
       o.index,
       address
FROM `bigquery-public-data.crypto_bitcoin.transactions` AS t,
     UNNEST(t.outputs) as o,
     UNNEST(o.addresses) as address
WHERE block_timestamp >= '{{ds}}' AND block_timestamp < TIMESTAMP_ADD('{{ds}}', INTERVAL 1 DAY)
