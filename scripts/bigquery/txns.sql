SELECT `hash`, block_number, size, virtual_size, version, lock_time, is_coinbase, input_count, output_count
FROM `bigquery-public-data.crypto_bitcoin.transactions`
WHERE DATE(block_timestamp) BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) AND CURRENT_DATE()
