/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

col c1 heading ‘Object|Name’        format a30
col c2 heading ‘Week Day’           format a15
col c3 heading ‘Invocation|Count’   format 99,999,999

break on c1 skip 2
break on c2 skip 2

select
  decode(c2,1,'Monday',2,'Tuesday',3,'Wednesday',4,'Thursday',5,'Friday',6,'Saturday',7,'Sunday') c2,
  c1,
  c3
from
(  
select
   p.object_name                       c1,
   to_char(sn.end_interval_time,'d')   c2,
   count(1)                            c3
from
  dba_hist_sql_plan   p,
  dba_hist_sqlstat    s,
  dba_hist_snapshot  sn
where
  p.object_owner <> 'SYS'  
and
  p.sql_id = s.sql_id
and
  s.snap_id = sn.snap_id    
group by
   p.object_name, 
   to_char(sn.end_interval_time,'d')
order by
  c2,c1
)
;

