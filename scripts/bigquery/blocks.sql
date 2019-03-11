SELECT 
 blocks.bits, 
 blocks.coinbase_param,
 blocks.`hash`,
 blocks.merkle_root,
 blocks.nonce,
 blocks.`number`,
 blocks.`size`,
 blocks.stripped_size,
 blocks.timestamp,
 blocks.transaction_count,
 blocks.version,
 blocks.weight
FROM `bigquery-public-data.crypto_bitcoin.blocks` as blocks
WHERE DATE(timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) AND DATE(timestamp) < CURRENT_DATE()
 AND number = 565759
