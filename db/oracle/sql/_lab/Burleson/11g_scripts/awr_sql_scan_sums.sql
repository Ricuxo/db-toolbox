/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

col c1 heading ‘Begin|Interval|Time’          format a20
col c2 heading ‘Large|Table|Full Table|Scans’ format 999,999
col c3 heading ‘Small|Table|Full Table|Scans’ format 999,999
col c4 heading ‘Total|Index|Scans’            format 999,999


select
  f.c1  c1,
  f.c2  c2,
  s.c2  c3,
  i.c2  c4
from  
(
select
  to_char(sn.begin_interval_time,'yy-mm-dd hh24')  c1,
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
  to_char(sn.begin_interval_time,'yy-mm-dd hh24')
order by
1 ) f,
(
select
  to_char(sn.begin_interval_time,'yy-mm-dd hh24')  c1,
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
   o.blocks < 1000
and
   p.operation like '%INDEX%'
and
   p.sql_id = s.sql_id
and
   s.snap_id = sn.snap_id   
group by
  to_char(sn.begin_interval_time,'yy-mm-dd hh24')
order by
1 ) s,
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
   p.operation like '%INDEX%'
and
   p.sql_id = s.sql_id
and
   s.snap_id = sn.snap_id   
group by
  to_char(sn.begin_interval_time,'yy-mm-dd hh24')
order by
1 ) i
where
      f.c1 = s.c1
  and
      f.c1 = i.c1
;

