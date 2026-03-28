/*  */
REM
REM NAME        : init_ora_rct.sql 
REM FUNCTION    : Recreate the instance init.ora file 
REM USE         : GENERAL
REM Limitations : None
REM
SET NEWPAGE 0 VERIFY OFF
SET ECHO OFF feedback off termout off PAGES 300 lines 80 heading off 
column name  format a80 word_wrapped
column dbname new_value db noprint
select name dbname from v$database;
DEFINE OUTPUT = 'rep_out\&db\init.ora'
SPOOL &OUTPUT
SELECT '# Init.ora file from v$parameter' name from dual
union
select '# generated on:'||sysdate name from dual
union 
select '# script by MRA 11/7/95 REVEALNET' name from dual
union
select '#' name from dual
UNION
SELECT name||' = '||value name  FROM V$PARAMETER
WHERE value is not null and ISDEFAULT='FALSE';
SPOOL OFF
CLEAR COLUMNS
SET NEWPAGE 0 VERIFY OFF
SET ECHO ON termout on PAGES 22 lines 80 heading on 
set termout on
undef output
pause Press enter to continue
