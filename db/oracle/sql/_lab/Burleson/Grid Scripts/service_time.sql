-- service_time.sql

SELECT
   a.inst_id "Instance",
   (a.value+b.value+c.value)/d.value "Current Blk Service Time"
FROM
  GV$SYSSTAT A,
  GV$SYSSTAT B,
  GV$SYSSTAT C,
  GV$SYSSTAT D
WHERE
  A.name = 'global cache current block pin time' AND
  B.name = 'global cache current block flush time' AND
  C.name = 'global cache current block send time' AND
  D.name = 'global cache current blocks served' AND
  B.inst_id=A.inst_id AND
  C.inst_id=A.inst_id AND
  D.inst_id=A.inst_id
ORDER BY
  a.inst_id;