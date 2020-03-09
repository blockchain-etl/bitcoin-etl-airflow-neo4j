select
   t.tx_seq_number,
   CONCAT(CAST(t.tx_seq_number AS STRING), '-', CAST(index AS STRING))
FROM `bigquery-public-data.crypto_bitcoin.outputs` AS o
LEFT JOIN crypto_bitcoin.txns AS t
  ON o.transaction_hash = t.`hash`
WHERE o.block_timestamp < '2010-01-01'
  AND o.transaction_hash NOT IN ('d5d27987d2a3dfc724e359870c6644b40e497bdc0589a033220fe15429d88599',
                                 'e3bf3d07d4b0375638d5f1db5255fe07ba2c4cb067cd81b84ee974b6585fb468')
