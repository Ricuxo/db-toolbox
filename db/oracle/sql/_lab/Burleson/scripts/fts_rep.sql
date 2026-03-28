/*  */
rem fts_rep.sql
rem FUNCTION: Full table scan report
rem MRA
rem
@title80 'Full Table Scans'
spool rep_out\&db\fts_rep
SELECT DISTINCT A.SID,
C.OWNER,
C.SEGMENT_NAME
FROM SYS.V_$SESSION_WAIT A,
SYS.V_$DATAFILE B,
SYS.DBA_EXTENTS C
WHERE A.P1 = B.FILE# AND
B.FILE# = C.FILE_ID AND
A.P2 BETWEEN C.BLOCK_ID AND 
(C.BLOCK_ID + C.BLOCKS) AND
A.EVENT = 'db file scattered read';
spool off
ttitle off
