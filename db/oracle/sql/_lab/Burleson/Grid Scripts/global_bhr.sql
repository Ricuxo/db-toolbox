-- global_bhr.sql

SELECT
  a.inst_id "Instance",
  (A.VALUE+B.VALUE+C.VALUE+D.VALUE)/(E.VALUE+F.VALUE) "GLOBAL CACHE HIT RATIO"
FROM
  GV$SYSSTAT A,
  GV$SYSSTAT B,
  GV$SYSSTAT C,
  GV$SYSSTAT D,
  GV$SYSSTAT E,
  GV$SYSSTAT F
WHERE
  A.NAME='global cache gets'
  AND B.NAME='global cache converts'
  AND C.NAME='global cache cr blocks received'
  AND D.NAME='global cache current blocks received'
  AND E.NAME='consistent gets'
  AND F.NAME='db block gets'
  AND B.INST_ID=A.INST_ID
  AND C.INST_ID=A.INST_ID
  AND D.INST_ID=A.INST_ID
  AND E.INST_ID=A.INST_ID
  AND F.INST_ID=A.INST_ID;