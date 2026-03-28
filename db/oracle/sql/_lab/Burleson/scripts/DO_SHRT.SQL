/*  */
REM
REM NAME        : do_shrt.sql
REM FUNCTION    : run the just_statistics procedure and gen report
REM FUNCTION    : the just_statistics procedure uses the dba_temp table
REM Limitations : None
REM
SET PAGES 58
SET NEWPAGE 0
REM SET ECHO OFF
REM set termout off
COLUMN TODAY NEW_VALUE _DATE
execute  dba_utilities.just_statistics;
START TITLE80 "CALCULATED STATISTICS REPORT"
DEFINE OUTPUT = rep_out\&db\do_shrt
SPOOL &&OUTPUT
SELECT name,value FROM DBA_TEMP
order by rep_order;
pause Press enter to continue
SPOOL OFF
set pages 22
ttitle off
undef output
