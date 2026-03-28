/*  */
rem  Name:     poolstat.sql
rem
rem  FUNCTION: Report on the various SGA components
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
select sum(bytes) sum_bytes from sys.v_$sgastat
where name != 'free memory';
start title80 'SGA Component Pools Report'
spool rep_out\&db\poolstat
select decode(pool,'','db_block_buffers',pool) pool,
sum(a.bytes) bytes,sum(a.bytes)/&divide_by*100  Percent
from sys.v_$sgastat a 
where a.name !='free memory'
group by decode(pool,'','db_block_buffers',pool)
union
select 'Free Memory '||pool,sum(bytes),0 
from sys.v_$sgastat a 
where a.name ='free memory'
group  by 'Free Memory '||pool
order by bytes desc
/
spool off
pause Press Enter to continue
clear columns
clear breaks
set pages 22 lines 80 feedback on verify on
ttitle off

