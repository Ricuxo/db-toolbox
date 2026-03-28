/*  */
REM
REM NAME                : RBK3.SQL
REM FUNCTION            : REPORT ON ROLLBACK SEGMENT HEALTH
REM FUNCTION            : USES THE ROLLBACK1 and ROLLBACK2 VIEWs
REM USE                 : FROM SQLPLUS
REM Limitations         : None
REM
COLUMN hwmsize          FORMAT 9999999999    HEADING 'LARGEST TRANS'
COLUMN tablespace_name  FORMAT a11		HEADING 'TABLESPACE'
COLUMN segment_name     FORMAT A10           HEADING 'ROLLBACK'
COLUMN optsize          FORMAT 9999999999   HEADING 'OPTL|SIZE'
COLUMN shrinks          FORMAT 9999           HEADING 'SHRINKS'
COLUMN aveshrink        FORMAT 9999999999   HEADING 'AVE|SHRINK'
COLUMN aveactive        FORMAT 9999999999   HEADING 'AVE|TRANS'
COLUMN waits            FORMAT 99999              HEADING 'WAITS'
COLUMN wraps            FORMAT 99999              HEADING 'WRAPS'
COLUMN extends          FORMAT 9999              HEADING 'EXTENDS'
rem
BREAK ON REPORT
COMPUTE AVG OF AVESHRINK ON REPORT
COMPUTE AVG OF AVEACTIVE ON REPORT
COMPUTE AVG OF SHRINKS ON REPORT
COMPUTE AVG OF WAITS ON REPORT
COMPUTE AVG OF WRAPS ON REPORT
COMPUTE AVG OF EXTENDS ON REPORT
COMPUTE AVG OF HWMSIZE ON REPORT
SET FEEDBACK OFF VERIFY OFF LINES 132 PAGES 47
@title132 "ROLLBACK SEGMENT HEALTH"
SPOOL rep_out\&db\rbk3
rem
SELECT c.tablespace_name, a.segment_name, a.optsize, a.shrinks, a.aveshrink, a.aveactive,
       b.hwmsize, b.waits, b.wraps, b.extends 
FROM (SELECT 
	d.segment_NAME,EXTENTS,
	OPTSIZE,SHRINKS,
	AVESHRINK,AVEACTIVE,
	d.STATUS
FROM 
V$ROLLNAME N, 
V$ROLLSTAT S,
dba_rollback_segs d
WHERE   
d.segment_id=n.usn(+) 
and d.segment_id=S.USN(+)) a, 

(SELECT d.segment_NAME, EXTENTS, XACTS,
HWMSIZE, RSSIZE, WAITS,
WRAPS,  EXTENDS
FROM    
V$ROLLNAME N,
V$ROLLSTAT S,
dba_rollback_segs d
WHERE
d.segment_id=n.usn(+) 
and d.segment_id=S.USN(+)) b, 
dba_rollback_segs c
where a.segment_name=b.segment_name
and c.segment_name=a.segment_name
ORDER BY tablespace_name, segment_name;
SPOOL OFF
CLEAR COLUMNS
TTITLE OFF
SET FEEDBACK ON VERIFY ON LINES 80 PAGES 22
PAUSE Press enter to continue
