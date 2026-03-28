/*  */

rem   Name     : TX_RBS.SQL
rem   Purpose: Generate a report of active rollbacks
rem   Use     : From SQL*Plus
rem   History:
rem   Date        Who                What
rem   Sept 91     Lan Nguyen      Presented in paper at IOUG
rem               Walter Lindsey 
rem   5/15/93     Mike Ault       Added Title80, sets and output
rem   1/04/97     Mike Ault       Verified against 7.3
rem   5/16/99     Mike Ault       Verified against Oracle8i
rem                               reformated added curext, curblk 
rem*************************************************************
COLUMN  name FORMAT a10         HEADING "Rollback|Segment"
COLUMN  pid  FORMAT 9999       HEADING "Ora|PID"
COLUMN  spid FORMAT 9999       HEADING "Sys|PID"
COLUMN  curext FORMAT 99999    HEADING "Curr|Extent"
COLUMN  curblk FORMAT 99999    HEADING "Curr|Block"
COLUMN  terminal FORMAT a10    HEADING "Terminal"
COLUMN transaction format a20 Heading 'Transaction'
SET PAGES 56  LINES 132 VERIFY OFF FEEDBACK OFF
ttitle "Rollback Segments in Use"
SPOOL tx_rbs
SELECT  
     r.name, l.Sid, spid, 
     NVL(p.username, 'no transaction') "Transaction",  
     p.terminal "Terminal",
     s.curext,s.curblk
FROM  
     v$lock l, 
     v$process p, 
     v$rollname r,
     v$rollstat s
WHERE 
         l.Sid = p.pid (+)
     AND TRUNC(l.id1(+) / 65536) = r.usn 
     AND l.type(+) = 'TX' 
     AND l.lmode(+) = 6
     AND r.usn=s.usn
ORDER BY r.name;
SPOOL OFF
SET PAGES 22  LINES 80 VERIFY ON FEEDBACK ON
CLEAR COLUMNS
TTITLE OFF

