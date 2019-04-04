SELECT
  t.block_number,
  t.hash
FROM `bigquery-public-data.crypto_bitcoin.transactions` AS t
WHERE block_timestamp < '2010-01-01'
  AND t.hash NOT IN ('d5d27987d2a3dfc724e359870c6644b40e497bdc0589a033220fe15429d88599',
                     'e3bf3d07d4b0375638d5f1db5255fe07ba2c4cb067cd81b84ee974b6585fb468')
