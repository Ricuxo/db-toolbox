/*  */
rem 
rem examine statements that have a high ratio (>100) and many executions.   These statements may need a 
rem rewrite.  Normally, any statement requiring over 50 buffers may be a contention point.  However, this threshold 
rem depends on the application. 
rem 
rem statements with high ratios are problems if they are OLTP.  DSS statements will get high buffers gets per 
rem execution. 
spool sql_issues3 
column piece noprint 
column exec  format 9999999 
column ratio format 999999.99 
column gets  format 99999999 
column parses  format 99999999 
column text  format a32 wrap 
column hash_value noprint
column address noprint
set pagesize 9999 
rem set heading off 
set pause off 
select distinct piece, 
          b.sql_text text, 
          buffer_gets gets, 
          buffer_gets/executions "ratio", 
          executions exec, 
          parse_calls parses,
	  a.hash_value,
	  a.address
from v$sqlarea a, v$sqltext b 
where executions > 1 
  and a.hash_value = b.hash_value 
  and a.address = b.address 
  and buffer_gets> 1000 
order by 4, a.hash_value, a.address, piece; 
spool off 
