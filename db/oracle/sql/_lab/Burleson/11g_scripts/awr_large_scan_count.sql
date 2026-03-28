/*  */
select
     sql_text, 
     total_large_scans, 
       executions, 
       executions * total_large_scans sum_large_scans 
from 
(select 
       sql_text, 
       count(*) total_large_scans, 
       executions 
 from 
       sys.v_$sql_plan a, 
       sys.dba_segments b, 
       sys.v_$sql c 
 where
       a.object_owner (+) = b.owner 
   and
       a.object_name (+) = b.segment_name 
   and
       b.segment_type IN ('TABLE', 'TABLE PARTITION') 
   and
       a.operation LIKE '%TABLE%' 
   and
       a.options = 'FULL' 
   and
       c.hash_value = a.hash_value 
   and
       b.bytes / 1024 > 1024 
   group by 
      sql_text, executions) 
order by
   4 desc
;
