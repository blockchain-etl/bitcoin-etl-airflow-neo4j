SELECT bits, coinbase_param, `hash`, merkle_root, nonce, number, size, stripped_size, timestamp, transaction_count, version, weight
FROM `bigquery-public-data.crypto_bitcoin.blocks`
WHERE DATE(timestamp) BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) AND CURRENT_DATE()
