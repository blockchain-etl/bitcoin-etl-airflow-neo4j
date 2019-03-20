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
WHERE number <= 300
-- WHERE DATE(timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) AND DATE(timestamp) < CURRENT_DATE()
