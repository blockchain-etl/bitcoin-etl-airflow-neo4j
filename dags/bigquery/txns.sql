SELECT t.`hash`,
       t.block_number,
       FORMAT_TIMESTAMP("%Y-%m-%dT%X%Ez", t.block_timestamp) AS block_timestamp,
       t.size,
       t.virtual_size,
       t.version,
       t.lock_time,
       t.is_coinbase,
       t.input_count,
       t.output_count
FROM `bigquery-public-data.crypto_bitcoin.transactions` AS t
WHERE block_timestamp >= '{{ds}}' AND block_timestamp < TIMESTAMP_ADD('{{ds}}', INTERVAL 1 DAY)
ORDER BY t.block_number
