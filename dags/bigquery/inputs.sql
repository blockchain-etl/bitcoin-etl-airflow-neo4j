SELECT t.`hash`,
       i.index,
       i.spent_transaction_hash,
       i.spent_output_index
FROM `bigquery-public-data.crypto_bitcoin.transactions` AS t,
     UNNEST(t.inputs) as i
WHERE block_timestamp >= '{{ds}}' AND block_timestamp < TIMESTAMP_ADD('{{ds}}', INTERVAL 1 DAY)
