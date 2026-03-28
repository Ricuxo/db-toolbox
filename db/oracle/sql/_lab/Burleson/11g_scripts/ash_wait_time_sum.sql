/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

select
   e.name                           "Wait Event",
   SUM(h.wait_time + h.time_waited) "Total Wait Time"
from
   v$active_session_history     h,
   v$event_name                 e
where
   h.event_id = e.event_id
and
   e.wait_class <> 'Idle'
group by
   e.name
order by 2 DESC
;
