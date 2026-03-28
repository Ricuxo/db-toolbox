/*  */
rem dbwr_stat.sql
rem Mike Ault - Burleson Consulting 11/09/01 Created
rem
col name format a46 heading 'DBWR Statistic'
rem col stat format 999,999,999,999,999 heading 'Statistic Value'
set pages 40
@title80 'DBWR Statistic Report'
spool rep_out\&db\dbwr_stat
select a.name,a.stat 
from  (select name, value stat from v$sysstat 
       where name not like '%redo%' and name not like '%remote%') a
where (a.name like 'DBWR%' or a.name like '%buffer%' or a.name like '%write%' or name like '%summed%') 
union
select class name, count stat from v$waitstat where class='data block'
union 
select name||' hit ratio' name, 
   round((1 - (a.physical_reads / greatest((a.db_block_gets + a.consistent_gets),1)) * 100),3) stat
from V$buffer_pool_statistics a
union 
select name||' free buffer wait' name,free_buffer_wait stat
from V$buffer_pool_statistics
union
select name||' buffer busy wait' name,buffer_busy_wait stat
from V$buffer_pool_statistics
union
select name||' write complete wait' name,write_complete_wait stat
from V$buffer_pool_statistics
/
spool off
set pages 22
ttitle off

