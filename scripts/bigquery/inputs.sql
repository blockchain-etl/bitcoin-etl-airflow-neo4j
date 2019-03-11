SELECT t.`hash`,
       i.index,
       i.spent_transaction_hash,
       i.spent_output_index
FROM `bigquery-public-data.crypto_bitcoin.transactions` AS t,
     UNNEST(t.inputs) as i
WHERE DATE(block_timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
  AND DATE(block_timestamp) < CURRENT_DATE()
