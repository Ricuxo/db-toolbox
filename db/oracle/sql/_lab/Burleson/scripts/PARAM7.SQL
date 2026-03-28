/*  */
REM
REM NAME        : PARAM7.SQL
REM FUNCTION    : GENERATE LIST OF DB PARAMETERS
REM USE         : GENERAL
REM Limitations : None
REM
SET NEWPAGE 0 VERIFY OFF
column num   format 999
column type  format 9999
column name  format a37
column value format a30
COLUMN ISDEFAULT FORMAT A8 HEADING "Default"
start title80 "INIT.ORA PARAMETER LISTING"
SET PAGES 43 lines 85
SPOOL rep_out\&db\param7
SELECT num,type,name,value FROM V$PARAMETER order by name;
SPOOL OFF
CLEAR COLUMNS
pause Press enter to continue
SET VERIFY ON termout on PAGES 22 lines 80
undef output
