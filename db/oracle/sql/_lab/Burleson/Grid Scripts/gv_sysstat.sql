-- gv_sysstat.sql

SELECT
   A.inst_id "Instance",
   (A.value/D.value) "Consistent Read Build",
   (B.value/D.value) "Log Flush Wait",
   (C.value/D.value) "Send Time"
FROM
  GV$SYSSTAT A,
  GV$SYSSTAT B,
  GV$SYSSTAT C,
  GV$SYSSTAT D
WHERE
  A.name = 'global cache cr block build time' AND
  B.name = 'global cache cr block flush time' AND
  C.name = 'global cache cr block send time' AND
  D.name = 'global cache cr blocks served' AND
  B.inst_id=a.inst_id AND
  C.inst_id=a.inst_id AND
  D.inst_id=a.inst_id
ORDER BY
  A.inst_id;

