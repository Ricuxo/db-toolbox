/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

col c1 heading ‘Begin|Interval|Time’   format a20
col c2 heading ‘Index|Range|Scans’ format 999,999
col c3 heading ‘Index|Unique|Scans’ format 999,999
col c4 heading ‘Index|Full|Scans’ format 999,999

select
  r.c1  c1,
  r.c2  c2,
  u.c2  c3,
  f.c2  c4
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
   p.operation like '%INDEX%'
and
   p.options like '%RANGE%'   
and
   p.sql_id = s.sql_id
and
   s.snap_id = sn.snap_id   
group by
  to_char(sn.begin_interval_time,'yy-mm-dd hh24')
order by
1 ) r,
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
   p.options like '%UNIQUE%'   
and
   p.sql_id = s.sql_id
and
   s.snap_id = sn.snap_id   
group by
  to_char(sn.begin_interval_time,'yy-mm-dd hh24')
order by
1 ) u,
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
   p.options like '%FULL%'   
and
   p.sql_id = s.sql_id
and
   s.snap_id = sn.snap_id   
group by
  to_char(sn.begin_interval_time,'yy-mm-dd hh24')
order by
1 ) f
where
      r.c1 = u.c1
  and
      r.c1 = f.c1
;
