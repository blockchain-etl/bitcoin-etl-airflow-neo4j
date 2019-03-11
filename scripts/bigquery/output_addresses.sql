SELECT `hash`,
       o.index,
       address
FROM `bigquery-public-data.crypto_bitcoin.transactions` AS t,
     UNNEST(t.outputs) as o,
     UNNEST(o.addresses) as address
WHERE DATE(block_timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
  AND DATE(block_timestamp) < CURRENT_DATE()
  AND t.`hash` = 'e5d9993b4809fe612a0e6690c02f82418efafe64e2623366c4545ea0a1c40bc4'
