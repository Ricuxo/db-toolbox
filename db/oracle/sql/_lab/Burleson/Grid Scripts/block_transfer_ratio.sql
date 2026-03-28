-- block_transfer_ratio.sql

SELECT
  A.INST_ID "Instance",
  A.VALUE/B.VALUE "BLOCK TRANSFER RATIO"
FROM
  GV$SYSSTAT A, GV$SYSSTAT B
WHERE
  A.NAME='global cache defers'
  AND B.NAME='global cache current blocks served'
  AND B.INST_ID=A.INST_ID;