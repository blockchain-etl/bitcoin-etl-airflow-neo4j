SELECT t.`hash`, o.index, o.required_signatures, o.type, o.value
FROM `bigquery-public-data.crypto_bitcoin.transactions` AS t, UNNEST(t.outputs) AS o
WHERE DATE(block_timestamp) BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) AND CURRENT_DATE()
