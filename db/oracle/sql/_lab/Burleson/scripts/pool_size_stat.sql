/*  */
rem  Name:     poolstat.sql
rem
rem  FUNCTION: Report on the various shared pool components
rem            and their sizes
rem
rem
column sum_bytes new_value divide_by noprint
column percent format 999.99999
column bytes format 999,999,999,999
col pool heading 'Pool'
set pages 60 lines 80 feedback off verify off
break on report
compute sum of bytes on report
compute sum of percent on report
select sum(value) sum_bytes from sys.v_$sga;
start title80 'Shared Pool Component Sizes Report'
spool rep_out\&db\pool_sizes
select a.name,a.bytes,a.bytes/&divide_by*100  Percent,pool
from sys.v_$sgastat a 
Where pool='shared pool'
order by bytes desc
/
spool off
pause Press Enter to continue
clear columns
clear breaks
set pages 22 lines 80 feedback on verify on
ttitle off

