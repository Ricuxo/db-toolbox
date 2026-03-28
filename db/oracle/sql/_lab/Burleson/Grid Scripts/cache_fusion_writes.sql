-- cache_fusion_writes.sql

SELECT
a.inst_id "Instance",
A.VALUE/B.VALUE "Cache Fusion Writes Ratio"
FROM
  GV$SYSSTAT A,
  GV$SYSSTAT B
WHERE
      a.name='DBWR XE "DBWR"  fusion writes'
  AND b.name='physical writes'
  AND b.inst_id=a.inst_id
ORDER BY
  A.INST_ID;