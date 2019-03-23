SELECT 
 blocks.bits, 
 blocks.coinbase_param,
 blocks.`hash`,
 blocks.merkle_root,
 blocks.nonce,
 blocks.`number`,
 blocks.`size`,
 blocks.stripped_size,
 FORMAT_TIMESTAMP("%Y-%m-%dT%X%Ez", blocks.timestamp) AS timestamp,
 blocks.transaction_count,
 blocks.version,
 blocks.weight
FROM `bigquery-public-data.crypto_bitcoin.blocks` as blocks
WHERE DATE(timestamp) >= '{{ds}}' AND DATE(timestamp) < DATE_ADD('{{ds}}', INTERVAL 1 {{var.value.INTERVAL}})
ORDER by blocks.number
