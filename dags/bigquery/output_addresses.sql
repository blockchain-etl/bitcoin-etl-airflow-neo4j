SELECT t.hash,
       t.block_number as block_height,
       o.index,
       address
FROM `bigquery-public-data.crypto_bitcoin.transactions` AS t,
     UNNEST(t.outputs) as o,
     UNNEST(o.addresses) as address
WHERE DATE(block_timestamp) >= '{{ds}}' AND DATE(block_timestamp) < DATE_ADD('{{ds}}', INTERVAL 1 {{var.value.INTERVAL}})
  AND EXTRACT(YEAR FROM DATE '{{ds}}') = EXTRACT(YEAR FROM block_timestamp)
ORDER BY t.hash, o.index
