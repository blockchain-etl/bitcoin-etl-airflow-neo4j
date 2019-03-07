SELECT `hash`, i.index, i.spent_transaction_hash
FROM `bigquery-public-data.crypto_bitcoin.transactions` AS t, UNNEST(t.inputs) as i
WHERE DATE(block_timestamp) BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) AND CURRENT_DATE()
