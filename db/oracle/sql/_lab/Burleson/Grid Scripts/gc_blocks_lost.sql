-- gc_blocks_lost.sql

SELECT A.INST_ID "INSTANCE", A.VALUE "GC BLOCKS LOST",
B.VALUE "GC CUR BLOCKS SERVED",
C.VALUE "GC CR BLOCKS SERVED",
A.VALUE/(B.VALUE+C.VALUE) RATIO
FROM GV$SYSSTAT A, GV$SYSSTAT B, GV$SYSSTAT C
WHERE A.NAME='global cache blocks lost' AND
      B.NAME='global cache current blocks served' AND
      C.NAME='global cache cr blocks served' and
      B.INST_ID=a.inst_id AND
      C.INST_ID = a.inst_id;