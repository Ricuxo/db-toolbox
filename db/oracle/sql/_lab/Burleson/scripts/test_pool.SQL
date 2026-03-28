/*  */
rem test_pool.sql
rem Produces one line report showing fill status for shared pool
rem
rem Mike Ault Burleson Consulting
rem
column shared_pool_used format 9,999.99
column shared_pool_size format 9,999.99
column shared_pool_avail format 9,999.99
column avail_pool_pct format 999.99
@title80 'Shared Pool Summary'
spool rep_out\&db\shared_pool
 select 
  least(max(b.value)/(1024*1024),sum(a.bytes)/(1024*1024)) shared_pool_used, 
  max(b.value)/(1024*1024) shared_pool_size,
  greatest(max(b.value)/(1024*1024),sum(a.bytes)/(1024*1024))-(sum(a.bytes)/(1024*1024)) shared_pool_avail,
  ((sum(a.bytes)/(1024*1024))/(max(b.value)/(1024*1024)))*100 filled_pool_pct
   from v$sgastat a, v$parameter b 
 where (a.pool='shared pool'
 and a.name not in ('free memory'))
 and
 b.name='shared_pool_size';
spool off
ttitle off
