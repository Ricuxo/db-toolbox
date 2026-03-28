/*  */
REM
REM NAME        : do_cals2.sql
REM FUNCTION    : run the cal_stat.sql procedure and gen report
REM FUNCTION    : the cal_stat procedure uses the dba_temp table
REM Limitations : None
REM
SET PAGES 58 LINES 79
SET NEWPAGE 0
SET ECHO OFF
set termout off feedback off verify off
COLUMN TODAY NEW_VALUE _DATE NOPRINT
COLUMN NAME FORMAT a32
select to_char(sysdate,'ddmonyyyyhh24mi') today from dual;
execute  dba_utilities.running_stats(TRUE);
START TITLE80 "CALCULATED STATISTICS REPORT"
DEFINE OUTPUT = rep_out\&db\cal_stat&&_date
SPOOL &&OUTPUT
SELECT name,value FROM DBA_TEMP
order by rep_order;
pause Press enter to continue
SPOOL OFF
set pages 22
ttitle off
undef output
