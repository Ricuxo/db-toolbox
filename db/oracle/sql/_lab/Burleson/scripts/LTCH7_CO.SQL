/*  */
REM
REM NAME        : LTCH7_CO.SQL 
REM FUNCTION    : Genereate latch contention report
REM USE         : From SQLPlus or other front end
REM Limitations : None
rem
COLUMN NAME   FORMAT A35
COLUMN RATIO1  FORMAT 999.9999
COLUMN RATIO2  FORMAT 999.9999
SET PAGES 58 NEWPAGE 0
start title80 "LATCH CONTENTION REPORT"
SPOOL rep_out\&db\latchs
SELECT A.NAME,100.*B.SLEEPS/B.getS RATIO1,
100.*b.immediate_misses/decode((b.immediate_misses+b.immediate_gets),0,1) ratio2 FROM
V$LATCHNAME A, V$LATCH B WHERE
A.LATCH# = B.LATCH# AND B.SLEEPS > 0
order by 2 desc;
SPOOL OFF
PAUSE PRESS RETURN TO CONTINUE
clear columns
ttitle off
set pages 22
