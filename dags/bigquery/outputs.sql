SELECT t.`hash`,
       t.block_number as block_height,
       o.index,
       o.required_signatures,
       o.type,
       o.value
FROM `bigquery-public-data.crypto_bitcoin.transactions` AS t,
     UNNEST(t.outputs) AS o
WHERE DATE(block_timestamp) >= '{{ds}}' AND DATE(block_timestamp) < DATE_ADD('{{ds}}', INTERVAL 1 {{var.value.INTERVAL}})
  AND EXTRACT(YEAR FROM DATE '{{ds}') = EXTRACT(YEAR FROM block_timestamp)
ORDER BY t.hash, o.index
