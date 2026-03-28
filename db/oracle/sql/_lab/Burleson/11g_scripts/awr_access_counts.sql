/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

ttile ‘Table Access|Operation Counts|Per Snapshot Period’

col c1 heading ‘Begin|Interval|time’ format a20
col c2 heading ‘Operation’           format a15
col c3 heading ‘Option’              format a15
col c4 heading ‘Object|Count’        format 999,999

break on c1 skip 2
break on c2 skip 2

select
  to_char(sn.begin_interval_time,'yy-mm-dd hh24')  c1,
  p.operation   c2, 
  p.options     c3,
  count(1)      c4
from
   dba_hist_sql_plan p,
   dba_hist_sqlstat  s,
   dba_hist_snapshot sn
where
   p.object_owner <> 'SYS'  
and
   p.sql_id = s.sql_id
and
   s.snap_id = sn.snap_id
group by
   to_char(sn.begin_interval_time,'yy-mm-dd hh24'),
   p.operation,
   p.options
order by
  1,2,3;
