SELECT t.`hash`,
       t.block_number as block_height,
       i.index,
       i.spent_transaction_hash,
       i.spent_output_index
FROM `bigquery-public-data.crypto_bitcoin.transactions` AS t,
     UNNEST(t.inputs) as i
WHERE DATE(block_timestamp) >= '{{ds}}' AND DATE(block_timestamp) < DATE_ADD('{{ds}}', INTERVAL 1 {{var.value.INTERVAL}})
ORDER BY t.hash, i.index
