/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

col c0 heading ‘Begin|Interval|time’ format a8
col c1 heading ‘Index|Name’          format a20
col c2 heading ‘Disk|Reads’          format 99,999,999
col c3 heading ‘Rows|Processed’      format 99,999,999
select
  to_char(s.begin_interval_time,'mm-dd hh24')  c0,
  p.object_name               c1,
  sum(t.disk_reads_total)     c2,
  sum(t.rows_processed_total) c3
from
       dba_hist_sql_plan p,
       dba_hist_sqlstat  t,
       dba_hist_snapshot s
where   
       p.sql_id = t.sql_id
   and
       t.snap_id = s.snap_id    
   and
       p.object_type like '%INDEX%'
group by
       to_char(s.begin_interval_time,'mm-dd hh24'),
       p.object_name      
order by        
       c0,c1,c2 desc
;
