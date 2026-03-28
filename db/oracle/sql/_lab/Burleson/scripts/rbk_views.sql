/*  */
CREATE OR REPLACE VIEW ROLLBACK1 AS
SELECT 
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
and d.segment_id=S.USN(+)
;

CREATE OR REPLACE VIEW ROLLBACK2 AS SELECT
d.segment_NAME,   EXTENTS,        XACTS,
HWMSIZE,        RSSIZE, WAITS,
WRAPS,  EXTENDS
FROM    
V$ROLLNAME N,
V$ROLLSTAT S,
dba_rollback_segs d
WHERE
d.segment_id=n.usn(+) 
and d.segment_id=S.USN(+);
