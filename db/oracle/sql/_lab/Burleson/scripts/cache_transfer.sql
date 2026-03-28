/*  */
col instance format 99999999
col name format a20
col kind format a10
set lines 80 pages 55
Select
INST_ID "Instance",
NAME,
KIND,
sum(FORCED_READS) "Forced Reads",
sum(FORCED_WRITES) "Forced Writes"
FROM GV$CACHE_TRANSFER
WHERE owner#!=0
GROUP BY INST_ID,NAME,KIND
ORDER BY 1,4 desc,2
/
