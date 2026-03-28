/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

break on begin_interval_time skip 0

column stat_name format a25

select
  begin_interval_time,
  new.stat_name,
  (new.value - old.value) Difference
from
   dba_hist_sys_time_model old,
   dba_hist_sys_time_model new,
   dba_hist_snapshot       ss
where
   new.stat_name = old.stat_name
and
   new.snap_id = ss.snap_id
and
   old.snap_id = ss.snap_id - 1
and
   new.stat_name like '%&stat_name%'
order by
   begin_interval_time
;
