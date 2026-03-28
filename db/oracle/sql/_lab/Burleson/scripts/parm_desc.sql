/*  */
REM
REM NAME        : PARAM_desc.SQL
REM FUNCTION    : GENERATE LIST OF DB PARAMETERS
REM USE         : GENERAL
REM Limitations : None
REM
SET NEWPAGE 0 VERIFY OFF
SET PAGES 10000 lines 131
column name  format a37
column value format a30 
column description format a40 word_wrapped
start title132 "INIT.ORA PARAMETER LISTING"
SPOOL rep_out\&db\param_desc
SELECT name,value,isdefault default,isses_modifiable ses, 
issys_modifiable sys, description 
FROM V$PARAMETER order by name;
SPOOL OFF
CLEAR COLUMNS
pause Press enter to continue
SET VERIFY ON termout on PAGES 22 lines 80
undef output
