-- block_pin.sql

SELECT
   A.inst_id "Instance",
   (A.value/D.value) "Current Block Pin",
   (B.value/D.value) "Log Flush Wait",
   (C.value/D.value) "Send Time"
FROM
  GV$SYSSTAT A,
  GV$SYSSTAT B,
  GV$SYSSTAT C,
  GV$SYSSTAT D
WHERE
  A.name = 'global cache current block build time' AND
  B.name = 'global cache current block flush time' AND
  C.name = 'global cache current block send time' AND
  D.name = 'global cache current blocks served' AND
  B.inst_id=a.inst_id AND
  C.inst_id=a.inst_id AND
  D.inst_id=a.inst_id
ORDER BY
  A.inst_id;