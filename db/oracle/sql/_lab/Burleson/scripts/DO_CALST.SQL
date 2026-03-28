/*  */
REM
REM NAME        : do_calst.sql
REM FUNCTION    : run the cal_stat.sql procedure and gen report
REM FUNCTION    : the cal_stat procedure uses the dba_temp table
REM Limitations : None
REM
SET PAGES 58
SET NEWPAGE 0
REM SET ECHO OFF
REM set termout off
COLUMN TODAY NEW_VALUE _DATE
start cal_stat.sql 
START TITLE80 "CALCULATED STATISTICS REPORT"
DEFINE OUTPUT = rep_out\&db\cal_stat
SPOOL &&OUTPUT
SELECT name,value FROM DBA_TEMP
order by rep_order;
pause Press enter to continue
SPOOL OFF
set pages 22
ttitle off
undef output
