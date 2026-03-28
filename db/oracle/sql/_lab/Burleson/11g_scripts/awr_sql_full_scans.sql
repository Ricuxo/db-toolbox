/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

col c1 heading ‘Begin|Interval|Time’   format a20
col c2 heading ‘Index|Table|Scans’ format 999,999
col c3 heading ‘Full|Table|Scans’ format 999,999

select
  i.c1  c1,
  i.c2  c2,
  f.c2  c3
from  
(
select
  to_char(sn.begin_interval_time,'yy-mm-dd hh24')  c1,
  count(1)                           c2
from
   dba_hist_sql_plan p,
   dba_hist_sqlstat  s,
   dba_hist_snapshot sn
where
   p.object_owner <> 'SYS'
and
   p.operation like '%TABLE ACCESS%'
and
   p.options like '%INDEX%'   
and
   p.sql_id = s.sql_id
and
   s.snap_id = sn.snap_id   
group by
  to_char(sn.begin_interval_time,'yy-mm-dd hh24')
order by
1 ) i,
(
select
  to_char(sn.begin_interval_time,'yy-mm-dd hh24')  c1,
  count(1)                           c2
from
   dba_hist_sql_plan p,
   dba_hist_sqlstat  s,
   dba_hist_snapshot sn
where
   p.object_owner <> 'SYS'
and
   p.operation like '%TABLE ACCESS%'
and
   p.options = 'FULL'   
and
   p.sql_id = s.sql_id
and
   s.snap_id = sn.snap_id   
group by
  to_char(sn.begin_interval_time,'yy-mm-dd hh24')
order by
1 ) f
where
      i.c1 = f.c1
;
