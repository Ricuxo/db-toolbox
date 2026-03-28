-- global_cache_blocks.sql

SELECT
      A.VALUE "GC BLOCKS LOST 1",
      B.VALUE "GC BLOCKS CORRUPT 1",
      C.VALUE "GC BLOCKS LOST 2",
      D.VALUE "GC BLOCKS CORRUPT 2"
FROM GV$SYSSTAT A, GV$SYSSTAT B, GV$SYSSTAT C, GV$SYSSTAT D
WHERE A.INST_ID=1 AND A.NAME='global cache blocks lost'
  AND B.INST_ID=1 AND B.NAME='global cache blocks corrupt'
  AND C.INST_ID=2 AND C.NAME='global cache blocks lost'
  AND D.INST_ID=2 AND D.NAME='global cache blocks corrupt';