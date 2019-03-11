SELECT t.`hash`,
       t.block_number,
       t.size,
       t.virtual_size,
       t.version,
       t.lock_time,
       t.is_coinbase,
       t.input_count,
       t.output_count
FROM `bigquery-public-data.crypto_bitcoin.transactions` AS t
WHERE DATE(block_timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
  AND DATE(block_timestamp) < CURRENT_DATE()
  AND t.`hash` = 'e5d9993b4809fe612a0e6690c02f82418efafe64e2623366c4545ea0a1c40bc4'
