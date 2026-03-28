/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

ttile ‘Large Table Full-table scans|Averages per Week Day’

col c1 heading ‘Week|Day’            format a20
col c2 heading ‘FTS|Count’           format 999,999

break on c1 skip 2
break on c2 skip 2

select
  to_char(sn.begin_interval_time,'day')  c1,
  count(1)                           c2
from
   dba_hist_sql_plan p,
   dba_hist_sqlstat  s,
   dba_hist_snapshot sn,
   dba_segments      o
where
   p.object_owner <> 'SYS'
and
   p.object_owner = o.owner  
and
   p.object_name = o.segment_name  
and
   o.blocks > 1000
and
   p.operation like '%TABLE ACCESS%'
and
   p.options like '%FULL%'
and
   p.sql_id = s.sql_id
and
   s.snap_id = sn.snap_id   
group by
  to_char(sn.begin_interval_time,'day')
order by
1;
