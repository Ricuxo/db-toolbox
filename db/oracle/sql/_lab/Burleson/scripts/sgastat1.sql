/*  */
rem  Name:     sgastat.sql
rem
rem  FUNCTION: Report on the various SGA components
rem            and their sizes
rem
rem
column sum_bytes new_value divide_by noprint
column percent format 999.99999
column bytes format 999,999,999,999
col pool heading 'Pool'
col name format a25 heading 'Area Name'
set pages 60 lines 80 feedback off verify off
break on report
compute sum of bytes on report
compute sum of percent on report
select sum(value) sum_bytes from sys.v_$sga;
start title80 'SGA Component Sizes Report'
spool rep_out\&db\sga_size
select a.name,a.bytes,a.bytes/&divide_by*100  Percent,pool
from sys.v_$sgastat a 
order by bytes desc
/
spool off
pause Press Enter to continue
clear columns
clear breaks
set pages 22 lines 80 feedback on verify on
ttitle off

