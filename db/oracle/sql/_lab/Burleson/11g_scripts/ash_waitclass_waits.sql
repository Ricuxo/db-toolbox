/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

break on begin_time skip 1

column wait_class format a15

select
  begin_time,
  wait_class,
  average_waiter_count,
  dbtime_in_wait
from
  dba_hist_waitclassmet_history
where
  dbtime_in_wait >10
order by
  begin_time,
  wait_class,
  average_waiter_count DESC
;
